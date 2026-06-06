import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var vibeStore: VibeStore
    @StateObject private var viewModel = ConversationViewModel()
    @State private var textInput = ""

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.canvas.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Emotion indicator
                    if let emotion = viewModel.latestEmotion {
                        EmotionBanner(emotion: emotion)
                    }

                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                ForEach(viewModel.messages) { msg in
                                    MessageBubble(message: msg)
                                        .id(msg.id)
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.top, DesignSystem.Spacing.md)
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            if let last = viewModel.messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                    }

                    Spacer()

                    // Voice orb + controls
                    VoiceControlArea(
                        isConnected: viewModel.isConnected,
                        isMuted: viewModel.isMuted,
                        agentIsSpeaking: viewModel.agentIsSpeaking,
                        connectionStatus: viewModel.connectionStatus,
                        onTapMic: { Task { await viewModel.toggleMute() } },
                        onTapConnect: {
                            Task {
                                if viewModel.isConnected {
                                    await viewModel.endConversation()
                                } else {
                                    await viewModel.startConversation()
                                }
                            }
                        }
                    )

                    // Text input fallback
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        TextField("Type a message...", text: $textInput)
                            .textFieldStyle(.roundedBorder)
                            .font(DesignSystem.Typography.bodyMd())

                        Button {
                            let msg = textInput
                            textInput = ""
                            Task { await viewModel.sendTextMessage(msg) }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        .disabled(textInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.sm)
                }
            }
            .navigationTitle("Curated")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Curated")
                        .font(DesignSystem.Typography.heading4())
                        .foregroundColor(DesignSystem.Colors.ink)
                }
            }
            .onAppear {
                viewModel.vibeStore = vibeStore
            }
        }
    }
}

// MARK: - Voice Control Area

private struct VoiceControlArea: View {
    let isConnected: Bool
    let isMuted: Bool
    let agentIsSpeaking: Bool
    let connectionStatus: String
    let onTapMic: () -> Void
    let onTapConnect: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Orb
            ZStack {
                Circle()
                    .fill(orbGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: DesignSystem.Colors.primary.opacity(agentIsSpeaking ? 0.5 : 0.1), radius: agentIsSpeaking ? 20 : 5)
                    .scaleEffect(agentIsSpeaking ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: agentIsSpeaking)

                Image(systemName: isConnected ? (isMuted ? "mic.slash.fill" : "mic.fill") : "waveform")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .onTapGesture(perform: isConnected ? onTapMic : onTapConnect)

            Text(connectionStatus)
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.steel)

            if !isConnected {
                CuratedButton(title: "Start Conversation", style: .primary, action: onTapConnect)
            } else {
                CuratedButton(title: "End", style: .secondary, action: onTapConnect)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xl)
    }

    private var orbGradient: LinearGradient {
        LinearGradient(
            colors: isConnected
                ? [DesignSystem.Colors.primary, DesignSystem.Colors.sunshine700]
                : [DesignSystem.Colors.stone, DesignSystem.Colors.muted],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ConversationMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer() }

            Text(message.content)
                .font(DesignSystem.Typography.bodyMd())
                .foregroundColor(message.role == .user ? .white : DesignSystem.Colors.ink)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    message.role == .user
                        ? DesignSystem.Colors.ink
                        : DesignSystem.Colors.cream
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))

            if message.role == .agent { Spacer() }
        }
    }
}

// MARK: - Emotion Banner

private struct EmotionBanner: View {
    let emotion: EmotionEvent

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: iconForEmotion(emotion.primaryEmotion))
                .foregroundColor(DesignSystem.Colors.primary)
            Text(emotion.primaryEmotion.capitalized)
                .font(DesignSystem.Typography.captionBold())
                .foregroundColor(DesignSystem.Colors.ink)
            Text("\(Int(emotion.confidence * 100))%")
                .font(DesignSystem.Typography.caption())
                .foregroundColor(DesignSystem.Colors.steel)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Colors.creamLight)
        .clipShape(Capsule())
        .padding(.top, DesignSystem.Spacing.xs)
    }

    private func iconForEmotion(_ emotion: String) -> String {
        switch emotion.lowercased() {
        case "happy": return "face.smiling"
        case "sad": return "face.dashed"
        case "angry": return "exclamationmark.triangle"
        default: return "minus.circle"
        }
    }
}
