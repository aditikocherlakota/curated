import SwiftUI

struct VibeProfileView: View {
    let profile: VibeProfile

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {

            // Aesthetic
            ProfileSection(title: "Aesthetic", icon: "paintpalette") {
                TagRow(tags: profile.aesthetic.keywords)
                ColorPaletteRow(hexColors: profile.aesthetic.colorPalette)
                if !profile.aesthetic.avoid.isEmpty {
                    AvoidRow(items: profile.aesthetic.avoid)
                }
            }

            // Fashion
            ProfileSection(title: "Fashion", icon: "tshirt") {
                InfoRow(label: "Silhouette", value: profile.fashion.silhouette)
                TagRow(tags: profile.fashion.fits)
                InfoRow(label: "Materials", value: profile.fashion.materials.joined(separator: ", "))
                InfoRow(label: "Footwear", value: profile.fashion.footwearBias.joined(separator: ", "))
                InfoRow(label: "Accessories", value: profile.fashion.accessories)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Loved brands")
                        .font(DesignSystem.Typography.captionBold())
                        .foregroundColor(DesignSystem.Colors.steel)
                    TagRow(tags: profile.fashion.lovedBrands)
                }
            }

            // Food & Drink
            ProfileSection(title: "Food & Drink", icon: "fork.knife") {
                TagRow(tags: profile.food.loves)
                InfoRow(label: "Ordering style", value: profile.food.orderingStyle)
                if !profile.food.avoids.isEmpty {
                    AvoidRow(items: profile.food.avoids)
                }
            }

            // Travel
            ProfileSection(title: "Travel", icon: "airplane") {
                InfoRow(label: "Style", value: profile.travel.style)
                InfoRow(label: "Pace", value: profile.travel.pace)
                InfoRow(label: "Lodging", value: profile.travel.lodging)
                TagRow(tags: profile.travel.lovedDestinations)
                if !profile.travel.avoids.isEmpty {
                    AvoidRow(items: profile.travel.avoids)
                }
            }

            // Interests & Music
            ProfileSection(title: "Interests", icon: "star") {
                TagRow(tags: profile.interests)
            }

            ProfileSection(title: "Music", icon: "music.note") {
                TagRow(tags: profile.music)
            }

            // Personality
            ProfileSection(title: "Personality", icon: "person.fill") {
                InfoRow(label: "Tone", value: profile.personality.tone)
                InfoRow(label: "Humor", value: profile.personality.humor)
                InfoRow(label: "Decisiveness", value: profile.personality.decisiveness)
                InfoRow(label: "Social energy", value: profile.personality.socialEnergy)
            }

            // Values
            ProfileSection(title: "Values", icon: "heart") {
                TagRow(tags: profile.values)
            }

            // Anti-vibe
            ProfileSection(title: "Anti-Vibe", icon: "xmark.octagon") {
                AvoidRow(items: profile.antiVibe)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Sub-components

private struct ProfileSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        CuratedCard(style: .base) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Label {
                    Text(title)
                        .font(DesignSystem.Typography.heading4())
                        .foregroundColor(DesignSystem.Colors.ink)
                } icon: {
                    Image(systemName: icon)
                        .foregroundColor(DesignSystem.Colors.primary)
                }

                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(DesignSystem.Typography.captionBold())
                .foregroundColor(DesignSystem.Colors.steel)
            Text(value)
                .font(DesignSystem.Typography.bodySm())
                .foregroundColor(DesignSystem.Colors.ink)
        }
    }
}

private struct TagRow: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: DesignSystem.Spacing.xxs) {
            ForEach(tags, id: \.self) { tag in
                CuratedBadge(text: tag, style: .cream)
            }
        }
    }
}

private struct AvoidRow: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Avoids")
                .font(DesignSystem.Typography.captionBold())
                .foregroundColor(DesignSystem.Colors.stone)
            Text(items.joined(separator: " \u{00B7} "))
                .font(DesignSystem.Typography.bodySm())
                .foregroundColor(DesignSystem.Colors.stone)
        }
    }
}

private struct ColorPaletteRow: View {
    let hexColors: [String]

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(hexColors, id: \.self) { hex in
                RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                    .fill(Color(hex: hex))
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                            .stroke(DesignSystem.Colors.hairline, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
