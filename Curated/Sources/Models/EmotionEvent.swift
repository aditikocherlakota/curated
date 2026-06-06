import Foundation

struct EmotionEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let primaryEmotion: String
    let confidence: Double
    let scores: [String: Double]
}

enum EmotionLabel: String, CaseIterable {
    case happy, sad, angry, neutral

    var displayName: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .happy: return "face.smiling"
        case .sad: return "face.dashed"
        case .angry: return "exclamationmark.triangle"
        case .neutral: return "minus.circle"
        }
    }
}
