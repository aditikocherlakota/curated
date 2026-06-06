import React from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors } from '../../constants/colors';
import { useVibe } from '../../context/VibeContext';
import { VibeProfile } from '../../types/vibe';

// ─── Primitives ──────────────────────────────────────────────────────────────

function Chip({ label }: { label: string }) {
  return (
    <View style={styles.chip}>
      <Text style={styles.chipText}>{label}</Text>
    </View>
  );
}

function ColorSwatch({ hex }: { hex: string }) {
  return <View style={[styles.swatch, { backgroundColor: hex }]} />;
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.infoRow}>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={styles.infoValue}>{value}</Text>
    </View>
  );
}

function ChipRow({ items }: { items: string[] }) {
  if (!items || items.length === 0) return null;
  return (
    <View style={styles.chipRow}>
      {items.map((item, i) => (
        <Chip key={i} label={item} />
      ))}
    </View>
  );
}

function SunsetStripe() {
  return (
    <LinearGradient
      colors={['#ffd06a', '#fa520f', '#cc3a05']}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 0 }}
      style={styles.sunsetStripe}
    />
  );
}

// ─── Section Card ─────────────────────────────────────────────────────────────

function SectionCard({
  icon,
  title,
  children,
}: {
  icon: string;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <View style={styles.card}>
      <View style={styles.cardHeader}>
        <Text style={styles.cardIcon}>{icon}</Text>
        <Text style={styles.cardTitle}>{title}</Text>
      </View>
      {children}
    </View>
  );
}

// ─── Profile Sections ─────────────────────────────────────────────────────────

function AestheticSection({ aesthetic }: { aesthetic: VibeProfile['aesthetic'] }) {
  return (
    <SectionCard icon="🎨" title="Aesthetic">
      <ChipRow items={aesthetic.keywords} />
      {aesthetic.color_palette && aesthetic.color_palette.length > 0 && (
        <View style={styles.swatchRow}>
          {aesthetic.color_palette.map((hex, i) => (
            <ColorSwatch key={i} hex={hex} />
          ))}
        </View>
      )}
      {aesthetic.avoid && aesthetic.avoid.length > 0 && (
        <Text style={styles.avoidsText}>Avoids: {aesthetic.avoid.join(', ')}</Text>
      )}
    </SectionCard>
  );
}

function FashionSection({ fashion }: { fashion: VibeProfile['fashion'] }) {
  return (
    <SectionCard icon="👕" title="Fashion">
      <InfoRow label="Silhouette" value={fashion.silhouette} />
      {fashion.materials && fashion.materials.length > 0 && (
        <InfoRow label="Materials" value={fashion.materials.join(', ')} />
      )}
      {fashion.footwear_bias && fashion.footwear_bias.length > 0 && (
        <InfoRow label="Footwear" value={fashion.footwear_bias.join(', ')} />
      )}
      {fashion.accessories ? (
        <InfoRow label="Accessories" value={fashion.accessories} />
      ) : null}
      {fashion.loved_brands && fashion.loved_brands.length > 0 && (
        <>
          <Text style={styles.subLabel}>Loved brands</Text>
          <ChipRow items={fashion.loved_brands} />
        </>
      )}
    </SectionCard>
  );
}

function FoodSection({ food }: { food: VibeProfile['food'] }) {
  return (
    <SectionCard icon="🍴" title="Food &amp; Drink">
      {food.loves && food.loves.length > 0 && (
        <>
          <Text style={styles.subLabel}>Loves</Text>
          <ChipRow items={food.loves} />
        </>
      )}
      {food.ordering_style ? (
        <InfoRow label="Ordering style" value={food.ordering_style} />
      ) : null}
      {food.avoids && food.avoids.length > 0 && (
        <Text style={styles.avoidsText}>Avoids: {food.avoids.join(', ')}</Text>
      )}
    </SectionCard>
  );
}

function TravelSection({ travel }: { travel: VibeProfile['travel'] }) {
  return (
    <SectionCard icon="✈️" title="Travel">
      {travel.style ? <InfoRow label="Style" value={travel.style} /> : null}
      {travel.pace ? <InfoRow label="Pace" value={travel.pace} /> : null}
      {travel.lodging ? <InfoRow label="Lodging" value={travel.lodging} /> : null}
      {travel.loved_destinations && travel.loved_destinations.length > 0 && (
        <>
          <Text style={styles.subLabel}>Loved destinations</Text>
          <ChipRow items={travel.loved_destinations} />
        </>
      )}
      {travel.avoids && travel.avoids.length > 0 && (
        <Text style={styles.avoidsText}>Avoids: {travel.avoids.join(', ')}</Text>
      )}
    </SectionCard>
  );
}

function InterestsSection({ interests }: { interests: string[] }) {
  return (
    <SectionCard icon="⭐" title="Interests">
      <ChipRow items={interests} />
    </SectionCard>
  );
}

function MusicSection({ music }: { music: string[] }) {
  return (
    <SectionCard icon="♪" title="Music">
      <ChipRow items={music} />
    </SectionCard>
  );
}

function PersonalitySection({ personality }: { personality: VibeProfile['personality'] }) {
  return (
    <SectionCard icon="👤" title="Personality">
      {personality.tone ? <InfoRow label="Tone" value={personality.tone} /> : null}
      {personality.humor ? <InfoRow label="Humor" value={personality.humor} /> : null}
      {personality.decisiveness ? (
        <InfoRow label="Decisiveness" value={personality.decisiveness} />
      ) : null}
      {personality.social_energy ? (
        <InfoRow label="Social energy" value={personality.social_energy} />
      ) : null}
    </SectionCard>
  );
}

function ValuesSection({ values }: { values: string[] }) {
  return (
    <SectionCard icon="❤️" title="Values">
      <ChipRow items={values} />
    </SectionCard>
  );
}

function AntiVibeSection({ antiVibe }: { antiVibe: string[] }) {
  return (
    <SectionCard icon="✕" title="Anti-Vibe">
      <Text style={styles.avoidsText}>Avoids: {antiVibe.join(', ')}</Text>
    </SectionCard>
  );
}

// ─── Empty State ──────────────────────────────────────────────────────────────

function EmptyState() {
  return (
    <View style={styles.emptyState}>
      <Text style={styles.emptyTitle}>No vibe profile loaded</Text>
      <Text style={styles.emptyBody}>
        Import a vibe.md file to see your taste profile here.
      </Text>
    </View>
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function VibeScreen() {
  const { profile } = useVibe();

  return (
    <ScrollView
      style={styles.scroll}
      contentContainerStyle={styles.scrollContent}
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.personIcon}>👤</Text>
        {profile ? (
          <Text style={styles.oneLiner}>{profile.one_liner}</Text>
        ) : (
          <Text style={styles.oneLinerPlaceholder}>Your taste, in your voice</Text>
        )}
      </View>

      <SunsetStripe />

      {/* Body */}
      <View style={styles.body}>
        {profile ? (
          <>
            <AestheticSection aesthetic={profile.aesthetic} />
            <FashionSection fashion={profile.fashion} />
            <FoodSection food={profile.food} />
            <TravelSection travel={profile.travel} />
            <InterestsSection interests={profile.interests} />
            <MusicSection music={profile.music} />
            <PersonalitySection personality={profile.personality} />
            <ValuesSection values={profile.values} />
            <AntiVibeSection antiVibe={profile.anti_vibe} />
          </>
        ) : (
          <EmptyState />
        )}

        {/* View raw vibe.md */}
        <TouchableOpacity style={styles.rawRow} activeOpacity={0.7}>
          <Text style={styles.rawRowText}>View raw vibe.md</Text>
          <Text style={styles.rawRowChevron}>›</Text>
        </TouchableOpacity>

        {/* App info */}
        <View style={styles.appInfo}>
          <Text style={styles.appName}>Curated</Text>
          <Text style={styles.appTagline}>Your taste, in your voice</Text>
        </View>
      </View>
    </ScrollView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  scroll: {
    flex: 1,
    backgroundColor: Colors.surface,
  },
  scrollContent: {
    paddingBottom: 40,
  },

  // Header
  header: {
    backgroundColor: Colors.cream,
    alignItems: 'center',
    paddingTop: 56,
    paddingBottom: 24,
    paddingHorizontal: 24,
  },
  personIcon: {
    fontSize: 64,
    marginBottom: 12,
  },
  oneLiner: {
    fontSize: 16,
    color: Colors.ink,
    textAlign: 'center',
    lineHeight: 22,
    fontStyle: 'italic',
  },
  oneLinerPlaceholder: {
    fontSize: 15,
    color: Colors.stone,
    textAlign: 'center',
  },

  // Sunset stripe
  sunsetStripe: {
    height: 4,
  },

  // Body
  body: {
    padding: 16,
  },

  // Card
  card: {
    backgroundColor: Colors.canvas,
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: 2,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  cardIcon: {
    fontSize: 18,
    marginRight: 8,
  },
  cardTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: Colors.ink,
  },

  // Chip
  chipRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 6,
    marginBottom: 8,
  },
  chip: {
    backgroundColor: Colors.cream,
    borderRadius: 100,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  chipText: {
    fontSize: 13,
    color: Colors.ink,
  },

  // Swatch
  swatchRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 6,
    marginBottom: 8,
  },
  swatch: {
    width: 32,
    height: 32,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: Colors.hairline,
  },

  // Info row
  infoRow: {
    marginBottom: 8,
  },
  infoLabel: {
    fontSize: 11,
    color: Colors.steel,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 2,
  },
  infoValue: {
    fontSize: 14,
    color: Colors.ink,
  },

  // Sub-label
  subLabel: {
    fontSize: 11,
    color: Colors.steel,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
    marginTop: 4,
  },

  // Avoids text
  avoidsText: {
    fontSize: 13,
    color: Colors.stone,
    fontStyle: 'italic',
    marginTop: 4,
  },

  // Empty state
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
    paddingHorizontal: 24,
  },
  emptyTitle: {
    fontSize: 17,
    fontWeight: '600',
    color: Colors.ink,
    marginBottom: 8,
  },
  emptyBody: {
    fontSize: 14,
    color: Colors.stone,
    textAlign: 'center',
    lineHeight: 20,
  },

  // Raw vibe row
  rawRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: Colors.canvas,
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: 2,
  },
  rawRowText: {
    fontSize: 14,
    color: Colors.ink,
  },
  rawRowChevron: {
    fontSize: 20,
    color: Colors.muted,
  },

  // App info
  appInfo: {
    alignItems: 'center',
    paddingBottom: 8,
  },
  appName: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.stone,
    letterSpacing: 0.5,
  },
  appTagline: {
    fontSize: 12,
    color: Colors.muted,
    marginTop: 2,
  },
});
