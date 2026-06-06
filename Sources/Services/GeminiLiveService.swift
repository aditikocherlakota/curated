import AVFoundation
import Foundation

/// Manages a Gemini Live API WebSocket session for real-time audio + video conversation.
/// Sends mic audio (16-bit PCM, 16 kHz) and camera frames (JPEG) to the model,
/// receives audio responses and plays them through the speaker.
@MainActor
final class GeminiLiveService: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var connectionStatus: String = "Ready"
    @Published var agentIsSpeaking = false
    @Published var inputTranscript: String = ""
    @Published var outputTranscript: String = ""

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var setupCompleted = false

    // Audio capture
    private var audioEngine: AVAudioEngine?
    private let captureQueue = DispatchQueue(label: "com.curated.gemini.capture")

    // Audio playback
    private var audioPlayerNode: AVAudioPlayerNode?
    private var playbackEngine: AVAudioEngine?
    private let playbackSampleRate: Double = 24000

    private let modelName = "gemini-2.5-flash-native-audio-preview-12-2025"

    private var vibeContext: String = ""

    func configure(vibeContext: String) {
        self.vibeContext = vibeContext
    }

    // MARK: - Connection

    func connect() async {
        let apiKey = Secrets.geminiAPIKey
        guard !apiKey.isEmpty else {
            connectionStatus = "Missing Gemini API Key"
            return
        }

        let endpoint = "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?key=\(apiKey)"

        guard let url = URL(string: endpoint) else {
            connectionStatus = "Invalid URL"
            return
        }

        connectionStatus = "Connecting..."

        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        urlSession = session
        let task = session.webSocketTask(with: url)
        webSocketTask = task
        task.resume()

        // Send config message (must be first message on the WebSocket)
        let systemPrompt = buildSystemPrompt()
        let configMessage: [String: Any] = [
            "setup": [
                "model": "models/\(modelName)",
                "generationConfig": [
                    "responseModalities": ["AUDIO"],
                    "speechConfig": [
                        "voiceConfig": [
                            "prebuiltVoiceConfig": [
                                "voiceName": "Aoede"
                            ]
                        ]
                    ]
                ],
                "systemInstruction": [
                    "parts": [["text": systemPrompt]]
                ],
                "inputAudioTranscription": [:],
                "outputAudioTranscription": [:]
            ]
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: configMessage)
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            print("[GeminiLive] Sending setup: \(jsonString.prefix(200))...")
            try await task.send(.string(jsonString))

            // Start receive loop and wait for setupComplete
            setupCompleted = false
            isConnected = true
            connectionStatus = "Waiting for session..."
            startReceiveLoop()

            // Wait for setupComplete before starting audio
            for _ in 0..<30 {
                try? await Task.sleep(nanoseconds: 200_000_000)
                if setupCompleted { break }
            }

            if setupCompleted {
                connectionStatus = "Session active"
                startAudioCapture()
            } else {
                connectionStatus = "Setup timeout"
                await disconnect()
            }
        } catch {
            connectionStatus = "Setup failed: \(error.localizedDescription)"
            print("[GeminiLive] Setup error: \(error)")
        }
    }

    func disconnect() async {
        stopAudioCapture()
        stopPlayback()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        isConnected = false
        setupCompleted = false
        connectionStatus = "Disconnected"
        inputTranscript = ""
        outputTranscript = ""
    }

    // MARK: - Send Video Frame

    nonisolated func sendVideoFrame(_ jpegData: Data) {
        let base64 = jpegData.base64EncodedString()
        let message: [String: Any] = [
            "realtimeInput": [
                "mediaChunks": [
                    [
                        "data": base64,
                        "mimeType": "image/jpeg"
                    ]
                ]
            ]
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: message) else { return }

        Task { @MainActor [weak self] in
            guard let self, self.isConnected, let task = self.webSocketTask else { return }
            task.send(.data(data)) { error in
                if let error { print("Send video frame error: \(error)") }
            }
        }
    }

    // MARK: - Audio Capture (Mic → Gemini)

    private func startAudioCapture() {
        // Configure audio session FIRST so the engine reports valid formats
        do {
            try configureAudioSession()
        } catch {
            print("Audio session config failed: \(error)")
            return
        }

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let nativeFormat = inputNode.outputFormat(forBus: 0)

        // Validate the native format before proceeding
        guard nativeFormat.sampleRate > 0, nativeFormat.channelCount > 0 else {
            print("Invalid mic format: \(nativeFormat). Mic may not be available (simulator?).")
            return
        }

        // We need 16 kHz mono PCM
        guard let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: 16000,
            channels: 1,
            interleaved: true
        ) else { return }

        guard let converter = AVAudioConverter(from: nativeFormat, to: targetFormat) else {
            print("Cannot create audio converter from \(nativeFormat) to \(targetFormat)")
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: nativeFormat) { [weak self] buffer, _ in
            guard let self else { return }
            let queue = self.captureQueue
            queue.async { [weak self] in
                self?.convertAndSendAudio(buffer, converter: converter, targetFormat: targetFormat)
            }
        }

        do {
            try engine.start()
            audioEngine = engine
        } catch {
            print("Audio engine start failed: \(error)")
        }
    }

    nonisolated private func convertAndSendAudio(
        _ buffer: AVAudioPCMBuffer,
        converter: AVAudioConverter,
        targetFormat: AVAudioFormat
    ) {
        let frameCount = AVAudioFrameCount(
            Double(buffer.frameLength) * targetFormat.sampleRate / buffer.format.sampleRate
        )
        guard frameCount > 0,
              let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: frameCount)
        else { return }

        var error: NSError?
        var inputConsumed = false
        converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
            if inputConsumed {
                outStatus.pointee = .noDataNow
                return nil
            }
            inputConsumed = true
            outStatus.pointee = .haveData
            return buffer
        }

        if let error { print("Audio conversion error: \(error)"); return }
        guard convertedBuffer.frameLength > 0 else { return }

        let byteCount = Int(convertedBuffer.frameLength) * 2 // 16-bit = 2 bytes
        let audioData = Data(bytes: convertedBuffer.int16ChannelData![0], count: byteCount)

        sendAudioChunk(audioData)
    }

    nonisolated private func sendAudioChunk(_ pcmData: Data) {
        let base64 = pcmData.base64EncodedString()
        let message: [String: Any] = [
            "realtimeInput": [
                "mediaChunks": [
                    [
                        "data": base64,
                        "mimeType": "audio/pcm;rate=16000"
                    ]
                ]
            ]
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: message) else { return }

        Task { @MainActor [weak self] in
            guard let self, let task = self.webSocketTask else { return }
            task.send(.data(data)) { error in
                if let error { print("Send audio error: \(error)") }
            }
        }
    }

    private func stopAudioCapture() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
    }

    // MARK: - Receive Loop

    private func startReceiveLoop() {
        Task { [weak self] in
            guard let self else { return }
            while let task = self.webSocketTask {
                do {
                    let message = try await task.receive()
                    await self.handleMessage(message)
                } catch {
                    print("[GeminiLive] Receive error: \(error)")
                    // Try to read close reason
                    if let task = self.webSocketTask {
                        print("[GeminiLive] Close code: \(task.closeCode.rawValue)")
                        if let reason = task.closeReason, let reasonStr = String(data: reason, encoding: .utf8) {
                            print("[GeminiLive] Close reason: \(reasonStr)")
                        }
                    }
                    if self.isConnected {
                        await MainActor.run {
                            self.connectionStatus = "Connection lost"
                            self.isConnected = false
                        }
                    }
                    break
                }
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) async {
        let data: Data
        switch message {
        case .data(let d):
            data = d
        case .string(let s):
            guard let d = s.data(using: .utf8) else { return }
            data = d
        @unknown default:
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("[GeminiLive] Failed to parse message")
            return
        }

        print("[GeminiLive] Received keys: \(json.keys.sorted())")

        // Handle setup complete
        if json["setupComplete"] != nil {
            await MainActor.run {
                self.setupCompleted = true
                self.connectionStatus = "Session active"
            }
            return
        }

        // Handle server content (audio responses, transcripts)
        if let serverContent = json["serverContent"] as? [String: Any] {
            await handleServerContent(serverContent)
        }
    }

    private func handleServerContent(_ content: [String: Any]) async {
        // Audio response from model
        if let modelTurn = content["modelTurn"] as? [String: Any],
           let parts = modelTurn["parts"] as? [[String: Any]] {
            for part in parts {
                if let inlineData = part["inlineData"] as? [String: Any],
                   let audioBase64 = inlineData["data"] as? String {
                    if let audioData = Data(base64Encoded: audioBase64) {
                        playAudioData(audioData)
                        await MainActor.run { self.agentIsSpeaking = true }
                    }
                }
            }
        }

        // Turn complete
        if let turnComplete = content["turnComplete"] as? Bool, turnComplete {
            await MainActor.run { self.agentIsSpeaking = false }
        }

        // Input transcription (what user said)
        if let inputTranscription = content["inputTranscription"] as? [String: Any],
           let text = inputTranscription["text"] as? String {
            await MainActor.run { self.inputTranscript = text }
        }

        // Output transcription (what model said)
        if let outputTranscription = content["outputTranscription"] as? [String: Any],
           let text = outputTranscription["text"] as? String {
            await MainActor.run { self.outputTranscript = text }
        }
    }

    // MARK: - Audio Playback

    private func playAudioData(_ pcmData: Data) {
        if playbackEngine == nil {
            setupPlayback()
        }

        guard let playerNode = audioPlayerNode,
              let format = AVAudioFormat(
                  commonFormat: .pcmFormatInt16,
                  sampleRate: 24000,
                  channels: 1,
                  interleaved: true
              ) else { return }

        let frameCount = AVAudioFrameCount(pcmData.count / 2)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else { return }

        buffer.frameLength = frameCount
        pcmData.withUnsafeBytes { rawBuffer in
            if let src = rawBuffer.baseAddress {
                memcpy(buffer.int16ChannelData![0], src, pcmData.count)
            }
        }

        playerNode.scheduleBuffer(buffer)
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    private func setupPlayback() {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        guard let format = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: playbackSampleRate,
            channels: 1,
            interleaved: true
        ) else {
            print("Cannot create playback format")
            return
        }

        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            playbackEngine = engine
            audioPlayerNode = player
        } catch {
            print("Playback engine start failed: \(error)")
        }
    }

    private func stopPlayback() {
        audioPlayerNode?.stop()
        playbackEngine?.stop()
        audioPlayerNode = nil
        playbackEngine = nil
    }

    // MARK: - Audio Session

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
    }

    // MARK: - System Prompt

    private func buildSystemPrompt() -> String {
        var prompt = """
        You are Curated, a personal style advisor with real-time vision. You can see the user through their camera.

        Your role in Fit Check mode:
        - Look at what the user is wearing and provide honest, constructive fashion feedback
        - Comment on fit, color coordination, proportions, and overall vibe
        - Suggest improvements or alternatives when something doesn't work
        - Be encouraging but honest — no empty flattery
        - Keep responses conversational and concise (2-3 sentences max per observation)
        - Reference specific items you can see ("that jacket", "those sneakers")
        - If you can't see clearly, ask the user to adjust the camera

        Speak naturally as if you're a stylish friend giving real-time advice. Be warm but direct.
        """

        if !vibeContext.isEmpty {
            prompt += "\n\nThe user's personal style profile:\n\(vibeContext)"
        }

        return prompt
    }
}
