import Foundation

struct VibeProfile: Codable, Identifiable {
    var id: String { vibeId }

    let vibeId: String
    let version: Int
    let generatedFrom: String
    let updated: String
    let oneLiner: String

    let aesthetic: Aesthetic
    let fashion: Fashion
    let interests: [String]
    let food: Food
    let travel: Travel
    let music: [String]
    let values: [String]
    let personality: Personality
    let communicationPrefs: CommunicationPrefs
    let engagementSignals: EngagementSignals
    let antiVibe: [String]
    let confidenceByDomain: [String: String]

    enum CodingKeys: String, CodingKey {
        case vibeId = "vibe_id"
        case version
        case generatedFrom = "generated_from"
        case updated
        case oneLiner = "one_liner"
        case aesthetic, fashion, interests, food, travel, music, values
        case personality
        case communicationPrefs = "communication_prefs"
        case engagementSignals = "engagement_signals"
        case antiVibe = "anti_vibe"
        case confidenceByDomain = "confidence_by_domain"
    }
}

struct Aesthetic: Codable {
    let keywords: [String]
    let colorPalette: [String]
    let avoid: [String]

    enum CodingKeys: String, CodingKey {
        case keywords
        case colorPalette = "color_palette"
        case avoid
    }
}

struct Fashion: Codable {
    let silhouette: String
    let fits: [String]
    let lovedBrands: [String]
    let avoidedBrands: [String]
    let materials: [String]
    let footwearBias: [String]
    let accessories: String

    enum CodingKeys: String, CodingKey {
        case silhouette, fits
        case lovedBrands = "loved_brands"
        case avoidedBrands = "avoided_brands"
        case materials
        case footwearBias = "footwear_bias"
        case accessories
    }
}

struct Food: Codable {
    let loves: [String]
    let avoids: [String]
    let orderingStyle: String

    enum CodingKeys: String, CodingKey {
        case loves, avoids
        case orderingStyle = "ordering_style"
    }
}

struct Travel: Codable {
    let style: String
    let pace: String
    let lodging: String
    let lovedDestinations: [String]
    let seeks: [String]
    let avoids: [String]

    enum CodingKeys: String, CodingKey {
        case style, pace, lodging
        case lovedDestinations = "loved_destinations"
        case seeks, avoids
    }
}

struct Personality: Codable {
    let tone: String
    let humor: String
    let decisiveness: String
    let socialEnergy: String

    enum CodingKeys: String, CodingKey {
        case tone, humor, decisiveness
        case socialEnergy = "social_energy"
    }
}

struct CommunicationPrefs: Codable {
    let assistantVoice: String
    let addressAs: String
    let avoid: [String]
    let brevity: String

    enum CodingKeys: String, CodingKey {
        case assistantVoice = "assistant_voice"
        case addressAs = "address_as"
        case avoid, brevity
    }
}

struct EngagementSignals: Codable {
    let mostLikedCategories: [String]
    let mostSaved: [String]
    let followsArchetypes: [String]
    let recurringHashtags: [String]
    let rarelyEngages: [String]

    enum CodingKeys: String, CodingKey {
        case mostLikedCategories = "most_liked_categories"
        case mostSaved = "most_saved"
        case followsArchetypes = "follows_archetypes"
        case recurringHashtags = "recurring_hashtags"
        case rarelyEngages = "rarely_engages"
    }
}
