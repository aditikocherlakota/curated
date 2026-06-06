import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors } from '../../constants/colors';
import { useVibe } from '../../context/VibeContext';

type Category = 'Fashion' | 'Food' | 'Travel' | 'Interiors' | 'Coffee';

const CATEGORIES: Category[] = ['Fashion', 'Food', 'Travel', 'Interiors', 'Coffee'];

const QUICK_PROMPTS: Record<Category, string[]> = {
  Fashion: [
    'Does this jacket work with my vibe?',
    'Find me straight-leg trousers in raw denim',
    'What should I wear to a gallery opening?',
  ],
  Food: [
    'Find me an omakase spot nearby',
    "Where's the best natural wine bar?",
    'What should I order at a Southeast Asian place?',
  ],
  Travel: [
    'Plan three days in Bangkok that feel like me',
    'Find a design hotel in Lisbon under $200',
    'What neighborhoods should I explore in Kyoto?',
  ],
  Interiors: [
    'Find me a mid-century credenza',
    'What ceramics would fit my space?',
    'Suggest a desk lamp under $300',
  ],
  Coffee: [
    'Best specialty coffee near me',
    'Find a roaster with single-origin Ethiopian',
    'Where can I get pour-over right now?',
  ],
};

interface HeroContent {
  title: string;
  subtitle: string;
}

function getHeroContent(
  category: Category,
  profile: NonNullable<ReturnType<typeof useVibe>['profile']>
): HeroContent {
  switch (category) {
    case 'Fashion':
      return {
        title: 'Your look',
        subtitle: `${profile.fashion.silhouette} · ${profile.fashion.materials.slice(0, 3).join(', ')}`,
      };
    case 'Food':
      return {
        title: 'Your table',
        subtitle: profile.food.loves.slice(0, 3).join(', '),
      };
    case 'Travel':
      return {
        title: 'Your trip',
        subtitle: `${profile.travel.style} · ${profile.travel.loved_destinations.slice(0, 3).join(', ')}`,
      };
    case 'Interiors':
      return {
        title: 'Your space',
        subtitle: profile.aesthetic.keywords.slice(0, 3).join(', '),
      };
    case 'Coffee':
      return {
        title: 'Your cup',
        subtitle: 'Third-wave, specialty, no chains',
      };
  }
}

function getConfidenceLabel(
  category: Category,
  confidence: Record<string, string>
): string {
  const key = category.toLowerCase();
  return confidence[key] ?? 'medium';
}

export default function RecommendationsScreen() {
  const { profile } = useVibe();
  const [selectedCategory, setSelectedCategory] = useState<Category>('Fashion');

  const prompts = QUICK_PROMPTS[selectedCategory];

  return (
    <SafeAreaView style={styles.safeArea}>
      {/* Category tabs */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.tabsContainer}
        style={styles.tabsScroll}
      >
        {CATEGORIES.map((cat) => {
          const isSelected = cat === selectedCategory;
          return (
            <TouchableOpacity
              key={cat}
              onPress={() => setSelectedCategory(cat)}
              style={[styles.tab, isSelected ? styles.tabSelected : styles.tabUnselected]}
              activeOpacity={0.75}
            >
              <Text style={[styles.tabText, isSelected ? styles.tabTextSelected : styles.tabTextUnselected]}>
                {cat}
              </Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

      {/* Sunset stripe */}
      <LinearGradient
        colors={['#ffd06a', '#fa520f', '#cc3a05']}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 0 }}
        style={styles.sunsetStripe}
      />

      <ScrollView style={styles.content} contentContainerStyle={styles.contentInner}>
        {profile ? (
          <>
            {/* Hero card */}
            <HeroCard category={selectedCategory} profile={profile} />

            {/* Quick asks */}
            <Text style={styles.sectionHeader}>Quick asks</Text>
            {prompts.map((prompt) => (
              <PromptRow key={prompt} prompt={prompt} />
            ))}

            {/* Confidence indicator */}
            <Text style={styles.confidence}>
              Vibe confidence: {getConfidenceLabel(selectedCategory, profile.confidence_by_domain)}
            </Text>
          </>
        ) : (
          <EmptyState />
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function HeroCard({
  category,
  profile,
}: {
  category: Category;
  profile: NonNullable<ReturnType<typeof useVibe>['profile']>;
}) {
  const { title, subtitle } = getHeroContent(category, profile);
  return (
    <View style={styles.heroCard}>
      <Text style={styles.heroTitle}>{title}</Text>
      <Text style={styles.heroSubtitle}>{subtitle}</Text>
    </View>
  );
}

function PromptRow({ prompt }: { prompt: string }) {
  return (
    <TouchableOpacity style={styles.promptRow} activeOpacity={0.7}>
      <Text style={styles.promptText}>{prompt}</Text>
      <Text style={styles.micIcon}>🎙</Text>
    </TouchableOpacity>
  );
}

function EmptyState() {
  return (
    <View style={styles.emptyState}>
      <Text style={styles.emptyIcon}>✨</Text>
      <Text style={styles.emptyText}>
        Build your vibe profile to get personalised recommendations.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: Colors.canvas,
  },
  tabsScroll: {
    flexGrow: 0,
    paddingTop: 12,
  },
  tabsContainer: {
    paddingHorizontal: 16,
    gap: 8,
    paddingBottom: 12,
  },
  tab: {
    paddingHorizontal: 16,
    paddingVertical: 7,
    borderRadius: 20,
  },
  tabSelected: {
    backgroundColor: Colors.ink,
  },
  tabUnselected: {
    borderWidth: 1,
    borderColor: Colors.hairline,
    backgroundColor: Colors.canvas,
  },
  tabText: {
    fontSize: 14,
    fontWeight: '500',
  },
  tabTextSelected: {
    color: Colors.canvas,
  },
  tabTextUnselected: {
    color: Colors.ink,
  },
  sunsetStripe: {
    height: 4,
    width: '100%',
  },
  content: {
    flex: 1,
  },
  contentInner: {
    padding: 20,
    paddingBottom: 40,
  },
  heroCard: {
    backgroundColor: Colors.cream,
    borderRadius: 16,
    padding: 20,
    marginBottom: 24,
  },
  heroTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: Colors.ink,
    marginBottom: 6,
  },
  heroSubtitle: {
    fontSize: 15,
    color: Colors.steel,
    lineHeight: 22,
  },
  sectionHeader: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.stone,
    textTransform: 'uppercase',
    letterSpacing: 0.8,
    marginBottom: 12,
  },
  promptRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
    paddingHorizontal: 16,
    backgroundColor: Colors.surface,
    borderRadius: 12,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: Colors.hairlineSoft,
  },
  promptText: {
    flex: 1,
    fontSize: 15,
    color: Colors.ink,
    marginRight: 12,
  },
  micIcon: {
    fontSize: 18,
  },
  confidence: {
    marginTop: 24,
    fontSize: 13,
    color: Colors.muted,
    textAlign: 'center',
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: 80,
  },
  emptyIcon: {
    fontSize: 40,
    marginBottom: 16,
  },
  emptyText: {
    fontSize: 16,
    color: Colors.stone,
    textAlign: 'center',
    lineHeight: 24,
    maxWidth: 260,
  },
});
