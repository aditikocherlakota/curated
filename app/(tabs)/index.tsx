import React, { useRef, useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  ScrollView,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Animated,
  KeyboardAvoidingView,
  Platform,
  SafeAreaView,
  Modal,
  ActivityIndicator,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useConversation } from '@elevenlabs/react-native';
import { Colors } from '../../constants/colors';
import { useVibe } from '../../context/VibeContext';

const BACKEND = process.env.EXPO_PUBLIC_BACKEND_BASE_URL ?? '';

const AGENT_ID = process.env.EXPO_PUBLIC_ELEVENLABS_AGENT_ID ?? '';

interface Message {
  id: string;
  role: 'user' | 'agent';
  content: string;
}

let _id = 0;
const nextId = () => String(++_id);

export default function TalkScreen() {
  const { systemPrompt, loadVibeFromMarkdown } = useVibe();

  // Instagram auth modal state
  const [showAuth, setShowAuth] = useState(false);
  const [igUsername, setIgUsername] = useState('');
  const [igPassword, setIgPassword] = useState('');
  const [twoFactor, setTwoFactor] = useState('');
  const [authStep, setAuthStep] = useState<'credentials' | 'loading' | 'error'>('credentials');
  const [authError, setAuthError] = useState('');

  const [messages, setMessages] = useState<Message[]>([]);
  const [textInput, setTextInput] = useState('');

  const scrollViewRef = useRef<ScrollView>(null);
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const pulseLoop = useRef<Animated.CompositeAnimation | null>(null);

  const { status, isSpeaking, startSession, endSession } = useConversation({
    onMessage: ({ message, source }) => {
      setMessages((prev) => [
        ...prev,
        { id: nextId(), role: source === 'user' ? 'user' : 'agent', content: message },
      ]);
    },
    onError: (error) => {
      console.error('ElevenLabs error:', error);
    },
  });

  const isConnected = status === 'connected';
  const isConnecting = status === 'connecting';

  const connectionStatus =
    status === 'connected'
      ? 'Connected'
      : status === 'connecting'
      ? 'Connecting...'
      : 'Ready';

  // Orb pulse when agent is speaking
  useEffect(() => {
    if (isSpeaking) {
      pulseLoop.current = Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, { toValue: 1.12, duration: 600, useNativeDriver: true }),
          Animated.timing(pulseAnim, { toValue: 1, duration: 600, useNativeDriver: true }),
        ])
      );
      pulseLoop.current.start();
    } else {
      pulseLoop.current?.stop();
      pulseAnim.setValue(1);
    }
    return () => pulseLoop.current?.stop();
  }, [isSpeaking, pulseAnim]);

  // Auto-scroll on new messages
  useEffect(() => {
    if (messages.length > 0) {
      setTimeout(() => scrollViewRef.current?.scrollToEnd({ animated: true }), 80);
    }
  }, [messages]);

  const launchSession = useCallback(async (prompt: string) => {
    await startSession({
      agentId: AGENT_ID,
      ...(prompt && {
        overrides: { agent: { prompt: { prompt } } },
      }),
    });
  }, [startSession]);

  const handleToggle = useCallback(async () => {
    if (isConnected || isConnecting) {
      await endSession();
      return;
    }
    // No real vibe yet — require Instagram auth first
    if (!systemPrompt) {
      setAuthStep('credentials');
      setAuthError('');
      setShowAuth(true);
      return;
    }
    await launchSession(systemPrompt);
  }, [isConnected, isConnecting, endSession, launchSession, systemPrompt]);

  const handleAuthSubmit = useCallback(async () => {
    if (!igUsername.trim() || !igPassword.trim()) return;
    setAuthStep('loading');
    setAuthError('');
    try {
      const res = await fetch(`${BACKEND}/vibe/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username: igUsername.trim(),
          password: igPassword,
          two_factor_code: twoFactor.trim() || undefined,
        }),
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.detail ?? `Error ${res.status}`);
      }
      const { vibe_md } = await res.json();
      loadVibeFromMarkdown(vibe_md);
      setShowAuth(false);
      await launchSession(
        "You are a talking mirror — a calm, direct, tasteful voice that reflects the user's aesthetic back to them.\n" +
        "You know their style, interests, and sensibility intimately because their taste profile is below.\n" +
        "Speak like a confident, warm friend with excellent taste. Never be sycophantic. Be brief and specific.\n\n" +
        vibe_md
      );
    } catch (e: unknown) {
      setAuthError(e instanceof Error ? e.message : 'Something went wrong');
      setAuthStep('error');
    }
  }, [igUsername, igPassword, twoFactor, loadVibeFromMarkdown, launchSession]);

  const handleSendText = useCallback(() => {
    const trimmed = textInput.trim();
    if (!trimmed || !isConnected) return;
    setMessages((prev) => [...prev, { id: nextId(), role: 'user', content: trimmed }]);
    setTextInput('');
    // ElevenLabs SDK handles text sending via the session — messages arrive via onMessage
  }, [textInput, isConnected]);

  const orbColors: [string, string, string] = isConnected
    ? [Colors.sunshine500, Colors.primary, Colors.primaryDeep]
    : ['#b0b0b0', '#808080', '#606060'];

  return (
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        keyboardVerticalOffset={88}
      >
        {/* Messages */}
        <ScrollView
          ref={scrollViewRef}
          style={styles.messageList}
          contentContainerStyle={styles.messageListContent}
          showsVerticalScrollIndicator={false}
        >
          {messages.length === 0 && (
            <Text style={styles.emptyHint}>Tap the orb to start a conversation.</Text>
          )}
          {messages.map((msg) => (
            <View
              key={msg.id}
              style={[styles.bubbleRow, msg.role === 'user' ? styles.rowUser : styles.rowAgent]}
            >
              <View style={[styles.bubble, msg.role === 'user' ? styles.bubbleUser : styles.bubbleAgent]}>
                <Text style={msg.role === 'user' ? styles.textUser : styles.textAgent}>
                  {msg.content}
                </Text>
              </View>
            </View>
          ))}
        </ScrollView>

        {/* Orb + controls */}
        <View style={styles.orbSection}>
          <Animated.View style={{ transform: [{ scale: pulseAnim }] }}>
            <TouchableOpacity onPress={handleToggle} activeOpacity={0.85}>
              <LinearGradient
                colors={orbColors}
                start={{ x: 0.2, y: 0 }}
                end={{ x: 0.8, y: 1 }}
                style={styles.orb}
              >
                <Text style={styles.orbIcon}>
                  {isConnected ? (isSpeaking ? '🔊' : '🎙️') : '〜'}
                </Text>
              </LinearGradient>
            </TouchableOpacity>
          </Animated.View>

          <Text style={styles.statusLabel}>{connectionStatus}</Text>

          <TouchableOpacity
            style={[styles.actionButton, isConnected ? styles.endButton : styles.startButton]}
            onPress={handleToggle}
            activeOpacity={0.8}
          >
            <Text style={styles.actionButtonText}>
              {isConnected ? 'End' : isConnecting ? 'Connecting...' : 'Start Conversation'}
            </Text>
          </TouchableOpacity>
        </View>

        {/* Text fallback */}
        <View style={styles.textRow}>
          <TextInput
            style={styles.textInput}
            value={textInput}
            onChangeText={setTextInput}
            placeholder="Type a message..."
            placeholderTextColor={Colors.muted}
            onSubmitEditing={handleSendText}
            returnKeyType="send"
          />
          <TouchableOpacity
            onPress={handleSendText}
            disabled={!textInput.trim() || !isConnected}
            style={styles.sendButton}
          >
            <Text style={[styles.sendIcon, (!textInput.trim() || !isConnected) && styles.sendIconDisabled]}>
              ↑
            </Text>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
      {/* Instagram auth modal */}
      <Modal visible={showAuth} transparent animationType="fade" onRequestClose={() => setShowAuth(false)}>
        <KeyboardAvoidingView
          style={styles.modalOverlay}
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        >
          <View style={styles.modalCard}>
            <Text style={styles.modalTitle}>Connect Instagram</Text>
            <Text style={styles.modalSubtitle}>
              Your recent posts will be read to build your taste profile.
            </Text>

            {authStep === 'loading' ? (
              <View style={styles.loadingBlock}>
                <ActivityIndicator size="large" color={Colors.primary} />
                <Text style={styles.loadingText}>Reading your posts...</Text>
              </View>
            ) : (
              <>
                <TextInput
                  style={styles.modalInput}
                  placeholder="Instagram username"
                  placeholderTextColor={Colors.muted}
                  value={igUsername}
                  onChangeText={setIgUsername}
                  autoCapitalize="none"
                  autoCorrect={false}
                />
                <TextInput
                  style={styles.modalInput}
                  placeholder="Password"
                  placeholderTextColor={Colors.muted}
                  value={igPassword}
                  onChangeText={setIgPassword}
                  secureTextEntry
                />
                <TextInput
                  style={styles.modalInput}
                  placeholder="2FA code (if enabled)"
                  placeholderTextColor={Colors.muted}
                  value={twoFactor}
                  onChangeText={setTwoFactor}
                  keyboardType="number-pad"
                />
                {authStep === 'error' && (
                  <Text style={styles.errorText}>{authError}</Text>
                )}
                <TouchableOpacity
                  style={[styles.modalButton, (!igUsername.trim() || !igPassword.trim()) && styles.modalButtonDisabled]}
                  onPress={handleAuthSubmit}
                  disabled={!igUsername.trim() || !igPassword.trim()}
                  activeOpacity={0.8}
                >
                  <Text style={styles.modalButtonText}>Build my vibe</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={() => setShowAuth(false)} style={styles.cancelButton}>
                  <Text style={styles.cancelText}>Cancel</Text>
                </TouchableOpacity>
              </>
            )}
          </View>
        </KeyboardAvoidingView>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: Colors.canvas },
  flex: { flex: 1 },
  messageList: { flex: 1 },
  messageListContent: { padding: 16, paddingBottom: 8, gap: 8 },
  emptyHint: { textAlign: 'center', color: Colors.muted, marginTop: 40, fontSize: 15 },
  bubbleRow: { flexDirection: 'row' },
  rowUser: { justifyContent: 'flex-end' },
  rowAgent: { justifyContent: 'flex-start' },
  bubble: { maxWidth: '78%', paddingHorizontal: 14, paddingVertical: 10, borderRadius: 18 },
  bubbleUser: { backgroundColor: Colors.ink },
  bubbleAgent: { backgroundColor: Colors.cream },
  textUser: { color: '#fff', fontSize: 15, lineHeight: 22 },
  textAgent: { color: Colors.ink, fontSize: 15, lineHeight: 22 },
  orbSection: { alignItems: 'center', paddingVertical: 28, gap: 12 },
  orb: { width: 100, height: 100, borderRadius: 50, alignItems: 'center', justifyContent: 'center' },
  orbIcon: { fontSize: 32 },
  statusLabel: { fontSize: 13, color: Colors.steel },
  actionButton: { paddingHorizontal: 28, paddingVertical: 12, borderRadius: 24 },
  startButton: { backgroundColor: Colors.primary },
  endButton: { backgroundColor: Colors.stone },
  actionButtonText: { color: '#fff', fontSize: 15, fontWeight: '600' },
  textRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingBottom: 12,
    gap: 8,
  },
  textInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: Colors.hairline,
    borderRadius: 20,
    paddingHorizontal: 14,
    paddingVertical: 10,
    fontSize: 15,
    color: Colors.ink,
    backgroundColor: Colors.surface,
  },
  sendButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sendIcon: { fontSize: 18, color: '#fff', fontWeight: '700' },
  sendIconDisabled: { opacity: 0.4 },

  // Instagram auth modal
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.45)',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  modalCard: {
    backgroundColor: Colors.canvas,
    borderRadius: 20,
    padding: 24,
    gap: 12,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: Colors.ink,
    marginBottom: 2,
  },
  modalSubtitle: {
    fontSize: 13,
    color: Colors.stone,
    lineHeight: 18,
    marginBottom: 4,
  },
  modalInput: {
    borderWidth: 1,
    borderColor: Colors.hairline,
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 11,
    fontSize: 15,
    color: Colors.ink,
    backgroundColor: Colors.surface,
  },
  modalButton: {
    backgroundColor: Colors.primary,
    borderRadius: 12,
    paddingVertical: 13,
    alignItems: 'center',
    marginTop: 4,
  },
  modalButtonDisabled: { opacity: 0.4 },
  modalButtonText: { color: '#fff', fontSize: 15, fontWeight: '600' },
  cancelButton: { alignItems: 'center', paddingVertical: 6 },
  cancelText: { fontSize: 14, color: Colors.stone },
  loadingBlock: { alignItems: 'center', paddingVertical: 20, gap: 12 },
  loadingText: { fontSize: 14, color: Colors.stone },
  errorText: { fontSize: 13, color: '#c0392b' },
});
