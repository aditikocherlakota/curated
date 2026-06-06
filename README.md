# Curated — iOS App

A voice assistant that knows your taste and acts on it. Point your camera at an outfit and ask if it fits your vibe. Ask it to plan a trip that feels like you. Every answer is filtered through `vibe.md`.

## Architecture

```
Curated/
├── Package.swift                  SPM manifest (Yams + ElevenLabs SDK)
├── Sources/
│   ├── App/
│   │   ├── CuratedApp.swift       @main entry point
│   │   └── ContentView.swift      Tab navigation (Talk, Fit Check, For You, Vibe)
│   ├── Design/
│   │   ├── DesignSystem.swift     Colors, typography, spacing from DESIGN.md
│   │   └── Components.swift       Reusable UI: buttons, cards, badges, sunset stripe
│   ├── Models/
│   │   ├── VibeProfile.swift      Typed struct matching the vibe.md YAML profile block
│   │   ├── EmotionEvent.swift     Valence emotion classification result
│   │   └── FitCheckResult.swift   Vision fit-check verdict + similar items
│   ├── Services/
│   │   ├── Secrets.swift          Loads API keys from env / Info.plist
│   │   ├── VibeStore.swift        Parses vibe.md → VibeProfile + narrative (via Yams)
│   │   ├── ValenceService.swift   Valence Pulse DiscreteAPI — emotion from voice audio
│   │   ├── APIService.swift       Backend API client (fit check, retrieve, itinerary)
│   │   ├── CameraService.swift    AVFoundation single-frame capture
│   │   └── AudioTapService.swift  Mic tap → PCM buffer → Valence per-turn emotion
│   ├── Views/
│   │   ├── Conversation/
│   │   │   ├── ConversationView.swift       Voice UI with orb, messages, text fallback
│   │   │   └── ConversationViewModel.swift  ElevenLabs SDK + Valence + client tools
│   │   ├── Camera/
│   │   │   ├── CameraView.swift             Camera preview + capture + fit check
│   │   │   └── CameraPreviewView.swift      UIViewRepresentable AVCaptureVideoPreviewLayer
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift           Profile header, vibe sections, raw MD link
│   │   │   ├── VibeProfileView.swift        Nice formatted display of the vibe profile
│   │   │   └── VibeMarkdownView.swift       Raw vibe.md rendered in-app
│   │   └── Recommendations/
│   │       └── RecommendationsView.swift    Category tabs + quick prompts
│   └── Info.plist                 Privacy descriptions + API key placeholders
└── Resources/
    └── sample_vibe.md             Bundled sample vibe file
```

## Setup

1. Open `Curated/` as a Swift Package in Xcode, or create a new iOS App project and add this package.
2. Add your API keys as Xcode scheme environment variables:
   - `ELEVENLABS_API_KEY` — your ElevenLabs API key
   - `ELEVENLABS_AGENT_ID` — your ElevenLabs Conversational AI agent ID
   - `VALENCE_API_KEY` — your Valence Pulse API key
   - `BACKEND_BASE_URL` — your FastAPI backend URL
3. Build and run on an iOS 17+ device (camera + mic required).

## Integration Contract

This app reads `vibe.md` and treats the `profile` YAML block as a fixed contract. The `VibeStore` parses it once per session into a `VibeProfile` typed object and holds the narrative as raw text for LLM context.

Your partner generates `vibe.md` from the Instagram Data Download. This app consumes it.

## Dependencies

- **[Yams](https://github.com/jpsim/Yams)** — YAML parsing for vibe.md profile block
- **[ElevenLabs Swift SDK](https://github.com/elevenlabs/elevenlabs-swift-sdk)** — Conversational AI voice loop (WebRTC, turn-taking, STT+TTS)
- **[Valence Pulse API](https://docs.getvalenceai.com)** — Emotion classification from voice audio (direct HTTPS, no SDK)
