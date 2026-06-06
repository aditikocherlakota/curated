import Foundation

struct FitCheckResult: Identifiable {
    let id = UUID()
    let timestamp: Date
    let verdict: String
    let works: String
    let doesNotWork: String
    let suggestions: [SimilarItem]
}

struct SimilarItem: Identifiable {
    let id = UUID()
    let title: String
    let url: URL?
    let source: String
}
