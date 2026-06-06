import Foundation

/// API keys loaded from the app's Info.plist or environment.
/// To configure: add ELEVENLABS_API_KEY and VALENCE_API_KEY to your
/// Xcode scheme environment variables, or add them to Info.plist
/// under the same keys.
enum Secrets {
    static var elevenLabsAPIKey: String {
        resolve("ELEVENLABS_API_KEY")
    }

    static var valenceAPIKey: String {
        resolve("VALENCE_API_KEY")
    }

    /// ElevenLabs Agent ID — create an agent in the ElevenLabs dashboard
    /// and paste its ID here or set it as ELEVENLABS_AGENT_ID.
    static var elevenLabsAgentId: String {
        resolve("ELEVENLABS_AGENT_ID")
    }

    static var geminiAPIKey: String {
        resolve("GEMINI_API_KEY")
    }

    static var elevenLabsVoiceId: String {
        resolve("ELEVENLABS_VOICE_ID")
    }

    static var backendBaseURL: String {
        resolve("BACKEND_BASE_URL", fallback: "https://your-backend.example.com")
    }

    private static func resolve(_ key: String, fallback: String = "") -> String {
        if let env = ProcessInfo.processInfo.environment[key], !env.isEmpty {
            return env
        }
        if let plist = Bundle.main.infoDictionary?[key] as? String, !plist.isEmpty {
            return plist
        }
        return fallback
    }
}
