import SwiftUI

struct CameraView: View {
    @EnvironmentObject var vibeStore: VibeStore
    @StateObject private var camera = CameraService()
    @State private var isAnalyzing = false
    @State private var result: FitCheckResult?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                if camera.isAuthorized {
                    CameraPreviewView(session: camera.session)
                        .ignoresSafeArea()
                } else {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.Colors.muted)
                        Text("Camera access needed for fit checks")
                            .font(DesignSystem.Typography.bodyMd())
                            .foregroundColor(DesignSystem.Colors.steel)
                        CuratedButton(title: "Open Settings", style: .secondary) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }

                VStack {
                    Spacer()

                    if let result {
                        FitCheckResultCard(result: result)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(DesignSystem.Typography.bodySm())
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                            .padding()
                    }

                    // Capture button
                    Button {
                        Task { await captureAndAnalyze() }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: 72, height: 72)
                            if isAnalyzing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(isAnalyzing)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
            .navigationTitle("Fit Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Fit Check")
                        .font(DesignSystem.Typography.heading4())
                        .foregroundColor(DesignSystem.Colors.ink)
                }
            }
        }
        .onDisappear { camera.stopSession() }
    }

    private func captureAndAnalyze() async {
        guard let vibeId = vibeStore.profile?.vibeId else {
            errorMessage = "No vibe profile loaded"
            return
        }

        isAnalyzing = true
        errorMessage = nil
        result = nil

        do {
            let frameData = try await camera.captureFrame()
            let fitResult = try await APIService.shared.fitCheck(frameJPEG: frameData, vibeId: vibeId)
            withAnimation { result = fitResult }
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }
}

// MARK: - Fit Check Result Card

struct FitCheckResultCard: View {
    let result: FitCheckResult

    var body: some View {
        CuratedCard(style: .cream) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Fit Check")
                    .font(DesignSystem.Typography.heading4())
                    .foregroundColor(DesignSystem.Colors.ink)

                Text(result.verdict)
                    .font(DesignSystem.Typography.bodyMd())
                    .foregroundColor(DesignSystem.Colors.ink)

                if !result.works.isEmpty {
                    Label {
                        Text(result.works)
                            .font(DesignSystem.Typography.bodySm())
                            .foregroundColor(DesignSystem.Colors.ink)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                if !result.doesNotWork.isEmpty {
                    Label {
                        Text(result.doesNotWork)
                            .font(DesignSystem.Typography.bodySm())
                            .foregroundColor(DesignSystem.Colors.ink)
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }

                if !result.suggestions.isEmpty {
                    Divider()
                    Text("Similar items")
                        .font(DesignSystem.Typography.captionBold())
                        .foregroundColor(DesignSystem.Colors.steel)
                    ForEach(result.suggestions) { item in
                        if let url = item.url {
                            Link(destination: url) {
                                HStack {
                                    Text(item.title)
                                        .font(DesignSystem.Typography.bodySm())
                                        .foregroundColor(DesignSystem.Colors.primary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                            }
                        } else {
                            Text(item.title)
                                .font(DesignSystem.Typography.bodySm())
                                .foregroundColor(DesignSystem.Colors.ink)
                        }
                    }
                }
            }
        }
    }
}
