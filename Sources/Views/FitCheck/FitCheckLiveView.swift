import SwiftUI

struct FitCheckLiveView: View {
    @EnvironmentObject var vibeStore: VibeStore
    @StateObject private var camera = CameraService()
    @StateObject private var gemini = GeminiLiveService()

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview
                if camera.isAuthorized {
                    CameraPreviewView(session: camera.session)
                        .ignoresSafeArea()
                } else {
                    cameraPermissionView
                }

                // Overlay UI
                VStack {
                    // Status bar
                    statusBar
                        .padding(.top, DesignSystem.Spacing.sm)

                    Spacer()

                    // Transcript overlay
                    if !gemini.outputTranscript.isEmpty || !gemini.inputTranscript.isEmpty {
                        transcriptOverlay
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }

                    // Controls
                    controlBar
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
        .task {
            camera.checkAuthorization()
            // Wait briefly for authorization callback, then auto-connect
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 200_000_000)
                if camera.isAuthorized { break }
            }
            if camera.isAuthorized && !gemini.isConnected {
                await startSession()
            }
        }
        .onDisappear {
            Task {
                camera.stopStreaming()
                camera.stopSession()
                await gemini.disconnect()
            }
        }
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(gemini.isConnected ? Color.green : DesignSystem.Colors.muted)
                .frame(width: 8, height: 8)

            Text(gemini.connectionStatus)
                .font(DesignSystem.Typography.caption())
                .foregroundColor(.white)

            Spacer()

            if gemini.agentIsSpeaking {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.caption2)
                    Text("Speaking")
                        .font(DesignSystem.Typography.caption())
                }
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    // MARK: - Transcript Overlay

    private var transcriptOverlay: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            if !gemini.inputTranscript.isEmpty {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                    Text("You:")
                        .font(DesignSystem.Typography.captionBold())
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(gemini.inputTranscript)
                        .font(DesignSystem.Typography.bodySm())
                        .foregroundColor(.white)
                }
            }

            if !gemini.outputTranscript.isEmpty {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                    Text("Curated:")
                        .font(DesignSystem.Typography.captionBold())
                        .foregroundColor(DesignSystem.Colors.sunshine500)
                    Text(gemini.outputTranscript)
                        .font(DesignSystem.Typography.bodySm())
                        .foregroundColor(.white)
                }
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }

    // MARK: - Control Bar

    private var controlBar: some View {
        HStack(spacing: DesignSystem.Spacing.xxl) {
            Spacer()

            // Main connect/disconnect button
            Button {
                Task {
                    if gemini.isConnected {
                        camera.stopStreaming()
                        await gemini.disconnect()
                    } else {
                        await startSession()
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(gemini.isConnected ? Color.red : DesignSystem.Colors.primary)
                        .frame(width: 72, height: 72)

                    if gemini.isConnected {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "video.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }

            Spacer()
        }
    }

    // MARK: - Camera Permission View

    private var cameraPermissionView: some View {
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

    // MARK: - Session Management

    private func startSession() async {
        // Pass vibe context to Gemini
        let vibeContext = vibeStore.profile?.styleSummary ?? ""
        gemini.configure(vibeContext: vibeContext)

        // Connect to Gemini Live
        await gemini.connect()

        // Start streaming camera frames
        camera.onFrame = { [weak gemini] jpegData in
            gemini?.sendVideoFrame(jpegData)
        }
        camera.startStreaming()
    }
}
