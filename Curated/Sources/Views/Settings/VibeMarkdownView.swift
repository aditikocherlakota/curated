import SwiftUI

struct VibeMarkdownView: View {
    let markdown: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                ForEach(parseBlocks(), id: \.id) { block in
                    switch block.kind {
                    case .heading(let level):
                        Text(block.text)
                            .font(level == 1 ? DesignSystem.Typography.heading2() :
                                  level == 2 ? DesignSystem.Typography.heading3() :
                                  DesignSystem.Typography.heading4())
                            .foregroundColor(DesignSystem.Colors.ink)
                            .padding(.top, level <= 2 ? DesignSystem.Spacing.md : DesignSystem.Spacing.xs)

                    case .code:
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(block.text)
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundColor(DesignSystem.Colors.canvas)
                                .padding(DesignSystem.Spacing.md)
                        }
                        .background(DesignSystem.Colors.surfaceCode)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))

                    case .blockquote:
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Rectangle()
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: 3)
                            Text(block.text)
                                .font(DesignSystem.Typography.bodySm())
                                .foregroundColor(DesignSystem.Colors.slate)
                        }
                        .padding(.vertical, DesignSystem.Spacing.xs)

                    case .paragraph:
                        Text(block.text)
                            .font(DesignSystem.Typography.bodyMd())
                            .foregroundColor(DesignSystem.Colors.ink)
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.canvas)
        .navigationTitle("vibe.md")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func parseBlocks() -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var inCodeBlock = false
        var codeBuffer = ""
        let lines = markdown.components(separatedBy: "\n")

        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    blocks.append(MarkdownBlock(kind: .code, text: codeBuffer.trimmingCharacters(in: .whitespacesAndNewlines)))
                    codeBuffer = ""
                    inCodeBlock = false
                } else {
                    inCodeBlock = true
                }
                continue
            }

            if inCodeBlock {
                codeBuffer += line + "\n"
                continue
            }

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if trimmed == "---" { continue }

            if trimmed.hasPrefix("###") {
                blocks.append(MarkdownBlock(kind: .heading(3), text: trimmed.replacingOccurrences(of: "### ", with: "")))
            } else if trimmed.hasPrefix("##") {
                blocks.append(MarkdownBlock(kind: .heading(2), text: trimmed.replacingOccurrences(of: "## ", with: "")))
            } else if trimmed.hasPrefix("#") {
                blocks.append(MarkdownBlock(kind: .heading(1), text: trimmed.replacingOccurrences(of: "# ", with: "")))
            } else if trimmed.hasPrefix(">") {
                blocks.append(MarkdownBlock(kind: .blockquote, text: trimmed.replacingOccurrences(of: "> ", with: "")))
            } else {
                blocks.append(MarkdownBlock(kind: .paragraph, text: trimmed))
            }
        }

        return blocks
    }
}

private struct MarkdownBlock: Identifiable {
    let id = UUID()
    let kind: Kind
    let text: String

    enum Kind {
        case heading(Int)
        case code
        case blockquote
        case paragraph
    }
}
