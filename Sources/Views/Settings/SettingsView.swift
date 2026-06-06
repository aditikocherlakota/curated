import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vibeStore: VibeStore

    @State private var showImportSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(DesignSystem.Colors.primary)

                        if let profile = vibeStore.profile {
                            Text(profile.oneLiner)
                                .font(DesignSystem.Typography.subtitle())
                                .foregroundColor(DesignSystem.Colors.ink)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DesignSystem.Spacing.xl)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.xxl)
                    .frame(maxWidth: .infinity)
                    .background(DesignSystem.Colors.creamLight)

                    SunsetStripe()

                    if let profile = vibeStore.profile {
                        VibeProfileView(profile: profile)
                            .padding(.top, DesignSystem.Spacing.md)
                    } else {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("No vibe profile loaded")
                                .font(DesignSystem.Typography.bodyMd())
                                .foregroundColor(DesignSystem.Colors.steel)
                            Text("Your partner generates vibe.md from your Instagram Data Download. Once loaded, your taste profile appears here.")
                                .font(DesignSystem.Typography.bodySm())
                                .foregroundColor(DesignSystem.Colors.stone)
                                .multilineTextAlignment(.center)
                        }
                        .padding(DesignSystem.Spacing.xxl)
                    }

                    // Vibe file section
                    NavigationLink {
                        VibeMarkdownView(markdown: vibeStore.rawMarkdown)
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(DesignSystem.Colors.primary)
                            Text("View raw vibe.md")
                                .font(DesignSystem.Typography.bodySmMedium())
                                .foregroundColor(DesignSystem.Colors.ink)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.muted)
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)

                    // App info
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text("Curated")
                            .font(DesignSystem.Typography.captionBold())
                            .foregroundColor(DesignSystem.Colors.steel)
                        Text("Your taste, in your voice")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.stone)
                    }
                    .padding(.vertical, DesignSystem.Spacing.xxl)
                }
            }
            .navigationTitle("Your Vibe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Vibe")
                        .font(DesignSystem.Typography.heading4())
                        .foregroundColor(DesignSystem.Colors.ink)
                }
            }
        }
    }
}
