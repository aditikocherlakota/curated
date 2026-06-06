import Foundation

final class APIService {
    static let shared = APIService()

    private var baseURL: String { Secrets.backendBaseURL }

    private init() {}

    // MARK: - Fit Check

    func fitCheck(frameJPEG: Data, vibeId: String) async throws -> FitCheckResult {
        let url = URL(string: "\(baseURL)/vision/fitcheck")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        // Frame image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"frame\"; filename=\"frame.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(frameJPEG)
        body.append("\r\n".data(using: .utf8)!)
        // Vibe ID
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"vibe_id\"\r\n\r\n".data(using: .utf8)!)
        body.append(vibeId.data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.requestFailed
        }

        return try parseFitCheckResponse(data)
    }

    private func parseFitCheckResponse(_ data: Data) throws -> FitCheckResult {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidResponse
        }

        let verdict = json["verdict"] as? String ?? ""
        let works = json["works"] as? String ?? ""
        let doesNotWork = json["does_not_work"] as? String ?? ""

        var suggestions: [SimilarItem] = []
        if let items = json["suggestions"] as? [[String: Any]] {
            suggestions = items.compactMap { item in
                guard let title = item["title"] as? String else { return nil }
                return SimilarItem(
                    title: title,
                    url: (item["url"] as? String).flatMap { URL(string: $0) },
                    source: item["source"] as? String ?? "web"
                )
            }
        }

        return FitCheckResult(
            timestamp: Date(),
            verdict: verdict,
            works: works,
            doesNotWork: doesNotWork,
            suggestions: suggestions
        )
    }

    // MARK: - Recommendations

    func retrieve(query: String, vibeId: String) async throws -> [[String: Any]] {
        let url = URL(string: "\(baseURL)/retrieve")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = ["query": query, "vibe_id": vibeId]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            return []
        }
        return results
    }

    // MARK: - Itinerary

    func itinerary(destination: String, days: Int, vibeId: String) async throws -> [[String: Any]] {
        let url = URL(string: "\(baseURL)/itinerary")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "destination": destination,
            "days": days,
            "vibe_id": vibeId,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let plan = json["plan"] as? [[String: Any]] else {
            return []
        }
        return plan
    }
}

enum APIError: Error, LocalizedError {
    case requestFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .requestFailed: return "Backend request failed"
        case .invalidResponse: return "Invalid response from backend"
        }
    }
}
