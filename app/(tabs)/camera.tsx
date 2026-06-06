import React, { useRef, useState } from 'react';
import {
  ActivityIndicator,
  Linking,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import { Colors } from '../../constants/colors';

interface FitCheckResult {
  verdict: string;
  works: string;
  doesNotWork: string;
  suggestions: { title: string; url?: string }[];
}

export default function CameraScreen() {
  const [permission, requestPermission] = useCameraPermissions();
  const [analyzing, setAnalyzing] = useState(false);
  const [result, setResult] = useState<FitCheckResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const cameraRef = useRef<CameraView>(null);

  if (!permission) {
    return <View style={styles.container} />;
  }

  if (!permission.granted) {
    return (
      <View style={styles.permissionContainer}>
        <Text style={styles.cameraIcon}>📷</Text>
        <Text style={styles.permissionMessage}>
          Camera access is required to check your fit.
        </Text>
        <Pressable
          style={styles.settingsButton}
          onPress={() => {
            if (permission.canAskAgain) {
              requestPermission();
            } else {
              Linking.openSettings();
            }
          }}
        >
          <Text style={styles.settingsButtonText}>Open Settings</Text>
        </Pressable>
      </View>
    );
  }

  const handleCapture = async () => {
    if (!cameraRef.current || analyzing) return;

    setAnalyzing(true);
    setResult(null);
    setError(null);

    try {
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.8,
        base64: false,
      });

      if (!photo) throw new Error('Failed to capture photo');

      const formData = new FormData();
      formData.append('image', {
        uri: photo.uri,
        type: 'image/jpeg',
        name: 'fit-check.jpg',
      } as unknown as Blob);
      formData.append('vibe_id', '');

      const response = await fetch(
        `${process.env.EXPO_PUBLIC_BACKEND_BASE_URL}/fit-check`,
        {
          method: 'POST',
          body: formData,
        }
      );

      if (!response.ok) {
        throw new Error(`Server error: ${response.status}`);
      }

      const data: FitCheckResult = await response.json();
      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong');
    } finally {
      setAnalyzing(false);
    }
  };

  return (
    <View style={styles.container}>
      <CameraView ref={cameraRef} style={StyleSheet.absoluteFill} facing="back" />

      {error && (
        <View style={styles.errorOverlay}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )}

      <View style={styles.bottomContainer}>
        {result && (
          <View style={styles.resultCard}>
            <Text style={styles.resultHeading}>Fit Check</Text>
            <Text style={styles.verdictText}>{result.verdict}</Text>

            <View style={styles.row}>
              <Text style={styles.checkIcon}>✓</Text>
              <Text style={styles.worksText}>{result.works}</Text>
            </View>

            <View style={styles.row}>
              <Text style={styles.crossIcon}>✕</Text>
              <Text style={styles.doesNotWorkText}>{result.doesNotWork}</Text>
            </View>

            {result.suggestions.length > 0 && (
              <ScrollView style={styles.suggestionsContainer} nestedScrollEnabled>
                {result.suggestions.map((suggestion, index) => (
                  <View key={index} style={styles.suggestionItem}>
                    {suggestion.url ? (
                      <Text
                        style={styles.suggestionLink}
                        onPress={() => Linking.openURL(suggestion.url!)}
                      >
                        {suggestion.title}
                      </Text>
                    ) : (
                      <Text style={styles.suggestionText}>{suggestion.title}</Text>
                    )}
                  </View>
                ))}
              </ScrollView>
            )}
          </View>
        )}

        <Pressable
          style={[styles.captureButton, analyzing && styles.captureButtonDisabled]}
          onPress={handleCapture}
          disabled={analyzing}
        >
          {analyzing ? (
            <ActivityIndicator color={Colors.canvas} />
          ) : (
            <Text style={styles.captureIcon}>📷</Text>
          )}
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.ink,
  },
  permissionContainer: {
    flex: 1,
    backgroundColor: Colors.canvas,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
    gap: 16,
  },
  permissionMessage: {
    fontSize: 16,
    color: Colors.steel,
    textAlign: 'center',
  },
  settingsButton: {
    backgroundColor: Colors.primary,
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  settingsButtonText: {
    color: Colors.canvas,
    fontSize: 16,
    fontWeight: '600',
  },
  errorOverlay: {
    position: 'absolute',
    top: 60,
    left: 16,
    right: 16,
    backgroundColor: 'rgba(200, 0, 0, 0.85)',
    borderRadius: 8,
    padding: 12,
  },
  errorText: {
    color: Colors.canvas,
    fontSize: 14,
    textAlign: 'center',
  },
  bottomContainer: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    alignItems: 'center',
    gap: 16,
    paddingHorizontal: 16,
  },
  resultCard: {
    width: '100%',
    backgroundColor: Colors.canvas,
    borderRadius: 16,
    padding: 16,
    gap: 8,
    shadowColor: Colors.ink,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 4,
  },
  resultHeading: {
    fontSize: 18,
    fontWeight: '700',
    color: Colors.ink,
  },
  verdictText: {
    fontSize: 14,
    color: Colors.steel,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 6,
  },
  worksText: {
    fontSize: 14,
    color: Colors.ink,
    flex: 1,
  },
  doesNotWorkText: {
    fontSize: 14,
    color: Colors.ink,
    flex: 1,
  },
  suggestionsContainer: {
    maxHeight: 120,
  },
  suggestionItem: {
    paddingVertical: 2,
  },
  suggestionLink: {
    fontSize: 14,
    color: Colors.primary,
    textDecorationLine: 'underline',
  },
  suggestionText: {
    fontSize: 14,
    color: Colors.ink,
  },
  captureButton: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: Colors.ink,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
    elevation: 6,
  },
  captureButtonDisabled: {
    opacity: 0.6,
  },
  cameraIcon: {
    fontSize: 64,
  },
  captureIcon: {
    fontSize: 32,
  },
  checkIcon: {
    fontSize: 16,
    color: 'green',
    fontWeight: '700',
  },
  crossIcon: {
    fontSize: 16,
    color: Colors.primary,
    fontWeight: '700',
  },
});
