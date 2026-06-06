export interface VibeProfile {
  vibe_id: string;
  version: number;
  generated_from: string;
  updated: string;
  one_liner: string;
  aesthetic: {
    keywords: string[];
    color_palette: string[];
    avoid: string[];
  };
  fashion: {
    silhouette: string;
    fits: string[];
    loved_brands: string[];
    avoided_brands: string[];
    materials: string[];
    footwear_bias: string[];
    accessories: string;
  };
  interests: string[];
  food: {
    loves: string[];
    avoids: string[];
    ordering_style: string;
  };
  travel: {
    style: string;
    pace: string;
    lodging: string;
    loved_destinations: string[];
    seeks: string[];
    avoids: string[];
  };
  music: string[];
  values: string[];
  personality: {
    tone: string;
    humor: string;
    decisiveness: string;
    social_energy: string;
  };
  communication_prefs: {
    assistant_voice: string;
    address_as: string;
    avoid: string[];
    brevity: string;
  };
  engagement_signals: {
    most_liked_categories: string[];
    most_saved: string[];
    follows_archetypes: string[];
    recurring_hashtags: string[];
    rarely_engages: string[];
  };
  anti_vibe: string[];
  confidence_by_domain: Record<string, string>;
}
