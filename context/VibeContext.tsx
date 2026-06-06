import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import yaml from 'js-yaml';
import { VibeProfile } from '../types/vibe';

const MIRROR_PROMPT_PREFIX =
  "You are a talking mirror — a calm, direct, tasteful voice that reflects the user's aesthetic back to them.\n" +
  "You know their style, interests, and sensibility intimately because their taste profile is below.\n" +
  "Speak like a confident, warm friend with excellent taste. Never be sycophantic. Be brief and specific.\n\n";

interface VibeContextType {
  profile: VibeProfile | null;
  rawMarkdown: string;
  systemPrompt: string;
  loadVibeFromMarkdown: (md: string) => void;
}

const VibeContext = createContext<VibeContextType>({
  profile: null,
  rawMarkdown: '',
  systemPrompt: '',
  loadVibeFromMarkdown: () => {},
});

function parseProfileFromMarkdown(md: string): VibeProfile | null {
  const match = md.match(/```yaml\n([\s\S]*?)```/);
  if (!match) return null;
  try {
    return yaml.load(match[1]) as VibeProfile;
  } catch {
    return null;
  }
}

export function VibeProvider({ children }: { children: React.ReactNode }) {
  const [profile, setProfile] = useState<VibeProfile | null>(null);
  const [rawMarkdown, setRawMarkdown] = useState('');

  const loadVibeFromMarkdown = useCallback((md: string) => {
    setRawMarkdown(md);
    setProfile(parseProfileFromMarkdown(md));
  }, []);

  // Sample vibe intentionally not auto-loaded — the talk screen prompts for
  // Instagram auth on first session start, which sets the real vibe.

  const systemPrompt = rawMarkdown ? `${MIRROR_PROMPT_PREFIX}${rawMarkdown}` : '';

  return (
    <VibeContext.Provider value={{ profile, rawMarkdown, systemPrompt, loadVibeFromMarkdown }}>
      {children}
    </VibeContext.Provider>
  );
}

export const useVibe = () => useContext(VibeContext);
