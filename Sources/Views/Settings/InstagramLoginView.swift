import SwiftUI

struct InstagramLoginView: View {
    @EnvironmentObject var vibeStore: VibeStore
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var twoFactorCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var needsTwoFactor = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "person.crop.square.filled.and.at.rectangle")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text("Connect Instagram")
                            .font(DesignSystem.Typography.heading3())
                            .foregroundColor(DesignSystem.Colors.ink)
                        Text("We'll read your last 50 posts and build your taste profile. Your credentials go directly to your backend — never stored by this app.")
                            .font(DesignSystem.Typography.bodySm())
                            .foregroundColor(DesignSystem.Colors.steel)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DesignSystem.Spacing.xl)

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        TextField("Instagram username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(DesignSystem.Typography.bodyMd())

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .font(DesignSystem.Typography.bodyMd())

                        if needsTwoFactor {
                            TextField("2FA code", text: $twoFactorCode)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .font(DesignSystem.Typography.bodyMd())
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(DesignSystem.Typography.bodySm())
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        CuratedButton(
                            title: isLoading ? "Analyzing your posts…" : "Generate My Vibe",
                            style: .primary
                        ) {
                            Task { await generate() }
                        }
                        .disabled(username.isEmpty || password.isEmpty || isLoading)
                        .padding(.horizontal, DesignSystem.Spacing.md)

                        if isLoading {
                            ProgressView()
                                .tint(DesignSystem.Colors.primary)
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Instagram")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }

    private func generate() async {
        isLoading = true
        errorMessage = nil
        do {
            let code = needsTwoFactor ? twoFactorCode : nil
            let vibeMd = try await APIService.shared.generateVibe(
                username: username,
                password: password,
                twoFactorCode: code
            )
            vibeStore.load(from: vibeMd)
            dismiss()
        } catch APIError.custom(let msg) where msg.contains("2FA") || msg.contains("two_factor") || msg.contains("session") {
            needsTwoFactor = true
            errorMessage = "Enter your Instagram 2FA code below."
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
