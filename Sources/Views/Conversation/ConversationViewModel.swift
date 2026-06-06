import Foundation
import Combine
import ElevenLabs

@MainActor
final class ConversationViewModel: ObservableObject {
    @Published var conversation: Conversation?
    @Published var connectionStatus: String = "Ready"
    @Published var isConnected = false
    @Published var isMuted = false
    @Published var agentIsSpeaking = false
    @Published var messages: [ConversationMessage] = []
    @Published var latestEmotion: EmotionEvent?

    private var cancellables = Set<AnyCancellable>()
    private let audioTap = AudioTapService()
    private var toolObserverTask: Task<Void, Never>?

    var vibeStore: VibeStore?

    init() {
        audioTap.$latestEmotion
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestEmotion)
    }

    func startConversation() async {
        let agentId = Secrets.elevenLabsAgentId
        guard !agentId.isEmpty else {
            connectionStatus = "Missing Agent ID"
            return
        }

        connectionStatus = "Connecting..."

        do {
            let vibeMd = vibeStore?.rawMarkdown ?? ""
            let systemPrompt = vibeMd.isEmpty ? nil : """
                You are a talking mirror — a calm, direct, tasteful voice that reflects the user's aesthetic back to them.
                You know their style, interests, and sensibility intimately because their taste profile is below.
                Speak like a confident, warm friend with excellent taste. Never be sycophantic. Be brief and specific.

                \(vibeMd)
                """
            let config = ConversationConfig(
                agentOverrides: AgentOverrides(prompt: systemPrompt),
                conversationOverrides: ConversationOverrides(textOnly: false)
            )

            let conv = try await ElevenLabs.startConversation(
                agentId: agentId,
                config: config
            )

            conversation = conv
            setupObservers()
            audioTap.startTap()
            connectionStatus = "Connected"
            isConnected = true
        } catch {
            connectionStatus = "Failed: \(error.localizedDescription)"
        }
    }

    func endConversation() async {
        guard let conversation else { return }
        await conversation.endConversation()
        toolObserverTask?.cancel()
        audioTap.stopTap()
        self.conversation = nil
        isConnected = false
        connectionStatus = "Ended"
    }

    func toggleMute() async {
        guard let conversation else { return }
        try? await conversation.toggleMute()
    }

    func sendTextMessage(_ text: String) async {
        guard let conversation else { return }
        try? await conversation.sendMessage(text)
    }

    private func setupObservers() {
        guard let conversation else { return }

        conversation.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .idle:
                    self?.connectionStatus = "Idle"
                    self?.isConnected = false
                case .connecting:
                    self?.connectionStatus = "Connecting..."
                case .active:
                    self?.connectionStatus = "Active"
                    self?.isConnected = true
                case .ended:
                    self?.connectionStatus = "Ended"
                    self?.isConnected = false
                case .error(let error):
                    self?.connectionStatus = "Error: \(error.localizedDescription)"
                    self?.isConnected = false
                }
            }
            .store(in: &cancellables)

        conversation.$agentState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .speaking:
                    self?.agentIsSpeaking = true
                case .listening:
                    self?.agentIsSpeaking = false
                default:
                    break
                }
            }
            .store(in: &cancellables)

        conversation.$isMuted
            .receive(on: DispatchQueue.main)
            .assign(to: &$isMuted)

        conversation.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msgs in
                self?.messages = msgs.map { msg in
                    ConversationMessage(
                        role: msg.role == .user ? .user : .agent,
                        content: msg.content
                    )
                }
            }
            .store(in: &cancellables)

        // Handle client tool calls (fit_check, etc.)
        toolObserverTask = Task {
            for await toolCalls in conversation.$pendingToolCalls.values {
                for toolCall in toolCalls {
                    await handleToolCall(toolCall)
                }
            }
        }
    }

    private func handleToolCall(_ toolCall: ClientToolCallEvent) async {
        let params = (try? toolCall.getParameters()) ?? [:]
        var result: [String: Any] = [:]

        switch toolCall.toolName {
        case "fit_check":
            // The agent triggers a fit check — app captures camera frame
            result = ["status": "fit_check_triggered", "message": "Camera frame requested"]

        case "find_similar":
            let query = params["query"] as? String ?? ""
            result = ["status": "searching", "query": query]

        default:
            result = ["error": "Unknown tool: \(toolCall.toolName)"]
        }

        try? await conversation?.sendToolResult(
            for: toolCall.toolCallId,
            result: result
        )
    }
}

struct ConversationMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role {
        case user, agent
    }
}
