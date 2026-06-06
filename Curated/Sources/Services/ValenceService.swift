import Foundation
import AVFoundation

final class ValenceService {
    static let shared = ValenceService()

    private var apiKey: String { Secrets.valenceAPIKey }
    private let endpoint = URL(string: "https://api.getvalenceai.com/emotionprediction")!

    private init() {}

    /// Analyze emotion from a short audio buffer (4-10s of PCM data).
    /// Converts to WAV, sends to Valence DiscreteAPI, returns an EmotionEvent.
    func analyzeEmotion(audioData: Data) async throws -> EmotionEvent {
        let wavData = wrapInWAV(pcmData: audioData, sampleRate: 44100, channels: 1, bitsPerSample: 16)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(wavData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ValenceError.requestFailed
        }

        return try parseResponse(data)
    }

    private func parseResponse(_ data: Data) throws -> EmotionEvent {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ValenceError.invalidResponse
        }

        let primaryEmotion = json["primary_emotion"] as? String ?? "neutral"
        let confidence = json["confidence"] as? Double ?? 0.0

        var scores: [String: Double] = [:]
        if let emotionScores = json["scores"] as? [String: Double] {
            scores = emotionScores
        }

        return EmotionEvent(
            timestamp: Date(),
            primaryEmotion: primaryEmotion,
            confidence: confidence,
            scores: scores
        )
    }

    private func wrapInWAV(pcmData: Data, sampleRate: Int, channels: Int, bitsPerSample: Int) -> Data {
        let byteRate = sampleRate * channels * bitsPerSample / 8
        let blockAlign = channels * bitsPerSample / 8
        let dataSize = pcmData.count
        let fileSize = 36 + dataSize

        var header = Data()
        header.append("RIFF".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(fileSize).littleEndian) { Data($0) })
        header.append("WAVE".data(using: .ascii)!)
        header.append("fmt ".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // PCM
        header.append(withUnsafeBytes(of: UInt16(channels).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt32(byteRate).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(blockAlign).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(bitsPerSample).littleEndian) { Data($0) })
        header.append("data".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        header.append(pcmData)

        return header
    }
}

enum ValenceError: Error, LocalizedError {
    case requestFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .requestFailed: return "Valence API request failed"
        case .invalidResponse: return "Invalid response from Valence API"
        }
    }
}
