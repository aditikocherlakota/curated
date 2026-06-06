import { Tabs } from 'expo-router';

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Talk' }} />
      <Tabs.Screen name="camera" options={{ title: 'Fit Check' }} />
      <Tabs.Screen name="recommendations" options={{ title: 'For You' }} />
      <Tabs.Screen name="vibe" options={{ title: 'Vibe' }} />
    </Tabs>
  );
}
