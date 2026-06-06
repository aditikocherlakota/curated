import Foundation

/// Stores conversation history for viewing past chats
@MainActor
final class ConversationHistoryStore: ObservableObject {
    static let shared = ConversationHistoryStore()

    @Published var conversations: [ConversationSession] = []

    private let saveKey = "conversation_history"
    private let maxConversations = 50

    init() {
        loadConversations()
    }

    func addConversation(_ session: ConversationSession) {
        conversations.insert(session, at: 0)

        // Keep only the most recent conversations
        if conversations.count > maxConversations {
            conversations = Array(conversations.prefix(maxConversations))
        }

        saveConversations()
    }

    func deleteConversation(at indexSet: IndexSet) {
        conversations.remove(atOffsets: indexSet)
        saveConversations()
    }

    func clearAll() {
        conversations.removeAll()
        saveConversations()
    }

    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadConversations() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([ConversationSession].self, from: data) else {
            return
        }
        conversations = decoded
    }
}

/// Represents a saved conversation session
struct ConversationSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let preview: String
    let messages: [SavedMessage]

    init(messages: [ConversationMessage]) {
        self.id = UUID()
        self.date = Date()
        self.messages = messages.map { SavedMessage(from: $0) }

        // Create preview from first user message or first few words
        if let firstUserMsg = messages.first(where: { $0.role == .user }) {
            self.preview = String(firstUserMsg.content.prefix(50))
        } else if let firstMsg = messages.first {
            self.preview = String(firstMsg.content.prefix(50))
        } else {
            self.preview = "Empty conversation"
        }
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SavedMessage: Codable, Identifiable {
    let id: UUID
    let role: String
    let content: String

    init(from message: ConversationMessage) {
        self.id = message.id
        self.role = message.role == .user ? "user" : "agent"
        self.content = message.content
    }
}
