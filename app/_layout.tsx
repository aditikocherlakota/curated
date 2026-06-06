import { Stack } from 'expo-router';
import { ConversationProvider } from '@elevenlabs/react-native';
import { VibeProvider } from '../context/VibeContext';

export default function RootLayout() {
  return (
    <ConversationProvider>
      <VibeProvider>
        <Stack screenOptions={{ headerShown: false }} />
      </VibeProvider>
    </ConversationProvider>
  );
}
