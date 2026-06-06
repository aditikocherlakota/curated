import AVFoundation
import Foundation

/// Captures PCM audio from the mic in short buffers for Valence emotion analysis.
/// Runs alongside the ElevenLabs voice session on a separate tap.
final class AudioTapService: ObservableObject {
    @Published var isRecording = false
    @Published var latestEmotion: EmotionEvent?

    private var audioEngine: AVAudioEngine?
    private var pcmBuffer = Data()
    private let bufferDuration: TimeInterval = 5.0 // seconds per Valence call
    private var bufferStartTime: Date?
    private var capturedSampleRate: Double = 48000
    private let bufferQueue = DispatchQueue(label: "com.curated.audiotap.buffer")

    func startTap() {
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        capturedSampleRate = format.sampleRate

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            self?.handleBuffer(buffer)
        }

        do {
            try engine.start()
            audioEngine = engine
            isRecording = true
            bufferQueue.sync { bufferStartTime = Date() }
        } catch {
            print("AudioTap start failed: \(error)")
        }
    }

    func stopTap() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isRecording = false
        bufferQueue.sync {
            pcmBuffer = Data()
            bufferStartTime = nil
        }
    }

    private func handleBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let frameCount = Int(buffer.frameLength)

        var int16Data = Data(capacity: frameCount * 2)
        for i in 0..<frameCount {
            let sample = max(-1.0, min(1.0, channelData[0][i]))
            var int16Sample = Int16(sample * Float(Int16.max))
            int16Data.append(Data(bytes: &int16Sample, count: 2))
        }

        let sampleRate = capturedSampleRate

        bufferQueue.sync {
            pcmBuffer.append(int16Data)

            guard let start = bufferStartTime, Date().timeIntervalSince(start) >= bufferDuration else {
                return
            }

            let audioData = pcmBuffer
            pcmBuffer = Data()
            bufferStartTime = Date()

            Task {
                do {
                    let emotion = try await ValenceService.shared.analyzeEmotion(audioData: audioData, sampleRate: Int(sampleRate))
                    await MainActor.run { self.latestEmotion = emotion }
                } catch {
                    print("Valence analysis failed: \(error)")
                }
            }
        }
    }
}
