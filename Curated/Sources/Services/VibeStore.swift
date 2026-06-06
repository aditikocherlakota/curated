import Foundation
import Combine
import Yams

@MainActor
final class VibeStore: ObservableObject {
    @Published var profile: VibeProfile?
    @Published var narrative: String = ""
    @Published var rawMarkdown: String = ""

    init() {
        loadBundledVibe()
    }

    func loadBundledVibe() {
        guard let url = Bundle.main.url(forResource: "sample_vibe", withExtension: "md"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return
        }
        parse(markdown: contents)
    }

    func load(from markdown: String) {
        parse(markdown: markdown)
    }

    private func parse(markdown: String) {
        rawMarkdown = markdown

        guard let yamlBlock = extractYAMLBlock(from: markdown) else { return }

        do {
            let decoder = YAMLDecoder()
            let decoded = try decoder.decode(VibeProfile.self, from: yamlBlock)
            profile = decoded
        } catch {
            print("VibeProfile parse error: \(error)")
        }

        if let narrativeRange = markdown.range(of: "## Narrative") {
            narrative = String(markdown[narrativeRange.lowerBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func extractYAMLBlock(from markdown: String) -> String? {
        let pattern = "```yaml\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: markdown, range: NSRange(markdown.startIndex..., in: markdown)),
              let range = Range(match.range(at: 1), in: markdown) else {
            return nil
        }
        return String(markdown[range])
    }
}
