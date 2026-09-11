import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/models.dart';
import '../providers/providers.dart';

class ActiveSessionState {
  const ActiveSessionState({
    this.session,
    this.messages = const [],
    this.moments = const [],
    this.isCoachTyping = false,
    this.error,
  });

  final Session? session;
  final List<ChatMessage> messages;
  final List<KeyMoment> moments;
  final bool isCoachTyping;
  final String? error;

  ActiveSessionState copyWith({
    Session? session,
    List<ChatMessage>? messages,
    List<KeyMoment>? moments,
    bool? isCoachTyping,
    String? error,
    bool clearError = false,
  }) {
    return ActiveSessionState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      moments: moments ?? this.moments,
      isCoachTyping: isCoachTyping ?? this.isCoachTyping,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  ActiveSessionNotifier(this._ref) : super(const ActiveSessionState());

  final Ref _ref;
  final _uuid = const Uuid();

  Future<void> startSession({required SportType sport, required bool isCompetition}) async {
    final session = await _ref.read(startSessionUseCaseProvider).call(
          sport: sport,
          isCompetition: isCompetition,
        );
    final assembler = _ref.read(contextAssemblerProvider);
    final history = await _ref.read(sessionRepositoryProvider).getAllSessions();
    final ctx = assembler.assemble(session: session, history: history, conversation: const []);
    final opener = await _ref.read(llmEngineProvider).respond(
          context: ctx,
          userInput: '',
          history: const [],
        );
    state = ActiveSessionState(
      session: session,
      messages: [ChatMessage(id: _uuid.v4(), role: ChatRole.coach, content: opener)],
    );
  }

  Future<void> setEnergyPre(int energy) async {
    final s = state.session;
    if (s == null) return;
    final updated = s.copyWith(energyLevelPre: energy);
    await _ref.read(updateSessionUseCaseProvider).call(updated);
    state = state.copyWith(session: updated);
  }

  Future<void> setPrimaryFocus(String focus) async {
    final s = state.session;
    if (s == null) return;
    final updated = s.copyWith(primaryFocus: focus);
    await _ref.read(updateSessionUseCaseProvider).call(updated);
    state = state.copyWith(session: updated);
  }

  Future<void> setAnchorWords(List<String> words) async {
    final s = state.session;
    if (s == null) return;
    final updated = s.copyWith(mentalAnchorWords: words);
    await _ref.read(updateSessionUseCaseProvider).call(updated);
    state = state.copyWith(session: updated);
  }

  Future<void> setHeadline(String headline) async {
    final s = state.session;
    if (s == null) return;
    final updated = s.copyWith(headline: headline, status: SessionPhase.postSession);
    await _ref.read(updateSessionUseCaseProvider).call(updated);
    state = state.copyWith(session: updated);
  }

  Future<void> setDominantEmotions(List<String> emotions) async {
    final s = state.session;
    if (s == null) return;
    final updated = s.copyWith(dominantEmotions: emotions);
    await _ref.read(updateSessionUseCaseProvider).call(updated);
    state = state.copyWith(session: updated);
  }

  Future<void> setEnergyPost(int energy) async {
    final s = state.session;
    if (s == null) return;
    final updated = s.copyWith(energyLevelPost: energy);
    await _ref.read(updateSessionUseCaseProvider).call(updated);
    state = state.copyWith(session: updated);
  }

  Future<void> addQuickNote({
    required String description,
    String? emotionTriggered,
    MomentType type = MomentType.learningMoment,
  }) async {
    final s = state.session;
    if (s == null) return;
    final moment = await _ref.read(addKeyMomentUseCaseProvider).call(
          sessionId: s.id,
          type: type,
          description: description,
          emotionTriggered: emotionTriggered,
        );
    state = state.copyWith(moments: [...state.moments, moment]);
  }

  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;
    final s = state.session;
    if (s == null) return;

    final userMsg = ChatMessage(id: _uuid.v4(), role: ChatRole.user, content: text, timestamp: DateTime.now());
    state = state.copyWith(messages: [...state.messages, userMsg], isCoachTyping: true, clearError: true);

    try {
      final assembler = _ref.read(contextAssemblerProvider);
      final history = await _ref.read(sessionRepositoryProvider).getAllSessions();
      final ctx = assembler.assemble(session: s, history: history, conversation: state.messages);
      final reply = await _ref.read(llmEngineProvider).respond(
            context: ctx,
            userInput: text,
            history: state.messages,
          );
      final coachMsg = ChatMessage(id: _uuid.v4(), role: ChatRole.coach, content: reply, timestamp: DateTime.now());
      state = state.copyWith(messages: [...state.messages, coachMsg], isCoachTyping: false);
    } catch (e) {
      state = state.copyWith(isCoachTyping: false, error: 'Coach konnte nicht antworten: $e');
    }
  }

  Future<MicroInsight?> finalizeReflection() async {
    final s = state.session;
    if (s == null) return null;
    try {
      final insight = await _ref.read(llmEngineProvider).generateInsight(
            session: s,
            moments: state.moments,
            conversation: state.messages,
          );
      final updated = s.copyWith(
        nextActionImpulse: insight.impulse,
        status: SessionPhase.completed,
        completedAt: DateTime.now(),
      );
      await _ref.read(updateSessionUseCaseProvider).call(updated);
      state = state.copyWith(session: updated);
      await _scheduleReminder(insight.impulse);
      return insight;
    } catch (e) {
      state = state.copyWith(error: 'Insight-Generierung fehlgeschlagen: $e');
      return null;
    }
  }

  Future<void> _scheduleReminder(String impulse) async {
    try {
      final when = DateTime.now().add(const Duration(hours: 2));
      await _ref.read(notificationEngineProvider).schedulePreSessionReminder(
            impulse: impulse,
            scheduledTime: when,
          );
    } catch (_) {}
  }

  void reset() {
    state = const ActiveSessionState();
  }
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>(
  (ref) => ActiveSessionNotifier(ref),
);
