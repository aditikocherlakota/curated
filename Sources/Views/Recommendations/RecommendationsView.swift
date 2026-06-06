import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject var vibeStore: VibeStore
    @State private var selectedTab = 0

    private let categories = ["Fashion", "Food", "Travel", "Interiors", "Coffee"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Category tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            ForEach(categories.indices, id: \.self) { index in
                                CategoryTab(
                                    title: categories[index],
                                    isSelected: selectedTab == index,
                                    action: { selectedTab = index }
                                )
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    }

                    SunsetStripe()

                    // Content
                    if let profile = vibeStore.profile {
                        ForYouContent(profile: profile, category: categories[selectedTab])
                            .padding(.top, DesignSystem.Spacing.md)
                    } else {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundColor(DesignSystem.Colors.muted)
                            Text("Load your vibe profile to get personalized recommendations")
                                .font(DesignSystem.Typography.bodyMd())
                                .foregroundColor(DesignSystem.Colors.steel)
                                .multilineTextAlignment(.center)
                        }
                        .padding(DesignSystem.Spacing.section)
                    }
                }
            }
            .navigationTitle("For You")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("For You")
                        .font(DesignSystem.Typography.heading4())
                        .foregroundColor(DesignSystem.Colors.ink)
                }
            }
        }
    }
}

// MARK: - Category Tab

private struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.bodySmMedium())
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.steel)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(isSelected ? DesignSystem.Colors.ink : DesignSystem.Colors.canvas)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? DesignSystem.Colors.ink : DesignSystem.Colors.hairline, lineWidth: 1)
                )
        }
    }
}

// MARK: - For You Content

private struct ForYouContent: View {
    let profile: VibeProfile
    let category: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Hero card based on category
            CuratedCard(style: .cream) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(heroTitle)
                        .font(DesignSystem.Typography.heading3())
                        .foregroundColor(DesignSystem.Colors.ink)
                    Text(heroSubtitle)
                        .font(DesignSystem.Typography.bodyMd())
                        .foregroundColor(DesignSystem.Colors.slate)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Quick actions
            SectionHeader("Quick asks", subtitle: "Tap to ask your assistant")

            ForEach(quickPrompts, id: \.self) { prompt in
                PromptCard(prompt: prompt)
            }

            // Confidence indicator
            if let confidence = profile.confidenceByDomain[category.lowercased()] {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "gauge")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text("Vibe confidence: \(confidence)")
                        .font(DesignSystem.Typography.caption())
                        .foregroundColor(DesignSystem.Colors.steel)
                }
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    private var heroTitle: String {
        switch category {
        case "Fashion": return "Your look"
        case "Food": return "Your table"
        case "Travel": return "Your trip"
        case "Interiors": return "Your space"
        case "Coffee": return "Your cup"
        default: return "For you"
        }
    }

    private var heroSubtitle: String {
        switch category {
        case "Fashion":
            return "\(profile.fashion.silhouette) \u{00B7} \(profile.fashion.materials.prefix(3).joined(separator: ", "))"
        case "Food":
            return profile.food.loves.prefix(3).joined(separator: ", ")
        case "Travel":
            return "\(profile.travel.style) \u{00B7} \(profile.travel.lovedDestinations.prefix(3).joined(separator: ", "))"
        case "Interiors":
            return profile.aesthetic.keywords.prefix(3).joined(separator: ", ")
        case "Coffee":
            return "Third-wave, specialty, no chains"
        default:
            return profile.oneLiner
        }
    }

    private var quickPrompts: [String] {
        switch category {
        case "Fashion":
            return [
                "Does this jacket work with my vibe?",
                "Find me straight-leg trousers in raw denim",
                "What should I wear to a gallery opening?",
            ]
        case "Food":
            return [
                "Find me an omakase spot nearby",
                "Where's the best natural wine bar?",
                "What should I order at a Southeast Asian place?",
            ]
        case "Travel":
            return [
                "Plan three days in Bangkok that feel like me",
                "Find a design hotel in Lisbon under $200",
                "What neighborhoods should I explore in Kyoto?",
            ]
        case "Interiors":
            return [
                "Find me a mid-century credenza",
                "What ceramics would fit my space?",
                "Suggest a desk lamp under $300",
            ]
        case "Coffee":
            return [
                "Best specialty coffee near me",
                "Find a roaster with single-origin Ethiopian",
                "Where can I get pour-over right now?",
            ]
        default:
            return []
        }
    }
}

// MARK: - Prompt Card

private struct PromptCard: View {
    let prompt: String

    var body: some View {
        HStack {
            Text(prompt)
                .font(DesignSystem.Typography.bodyMd())
                .foregroundColor(DesignSystem.Colors.ink)
            Spacer()
            Image(systemName: "mic.fill")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .stroke(DesignSystem.Colors.hairlineSoft, lineWidth: 1)
        )
    }
}
