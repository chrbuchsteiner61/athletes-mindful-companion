import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/json_store.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/services/secure_storage_service.dart';
import '../../data/services/mock_llm_engine.dart';
import '../../data/services/mistral_llm_engine.dart';
import '../../data/services/notification_engine.dart';
import '../../data/services/speech_to_text_service.dart';
import '../../domain/services/context_assembler.dart';
import '../../domain/services/llm_engine.dart';
import '../../domain/services/trend_analyzer.dart';
import '../../domain/usecases/session_usecases.dart';

final jsonStoreProvider = Provider<JsonStore>((ref) => JsonStore());

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(jsonStoreProvider)),
);

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final notificationEngineProvider = Provider<NotificationEngine>(
  (ref) => NotificationEngine(),
);

final speechToTextProvider = Provider<SpeechToTextService>(
  (ref) => SpeechToTextService(),
);

final trendAnalyzerProvider = Provider<TrendAnalyzer>((ref) => TrendAnalyzer());
final patternDetectorProvider = Provider<PatternDetector>((ref) => PatternDetector());

final systemPromptProvider = FutureProvider<String>((ref) async {
  try {
    return await rootBundle.loadString('assets/prompts/system_prompt.txt');
  } catch (_) {
    return 'Du bist der Athlete\'s Mindful Companion, ein empathischer Mentalcoach. Antworte kurz, sportbezogen, wertfrei und fragend.';
  }
});

final contextAssemblerProvider = Provider<ContextAssembler>((ref) {
  final prompt = ref.watch(systemPromptProvider).maybeWhen(
        data: (p) => p,
        orElse: () => 'Du bist der Athlete\'s Mindful Companion.',
      );
  return ContextAssembler(prompt);
});

final llmEngineProvider = Provider<LlmEngine>((ref) {
  final secure = ref.watch(secureStorageProvider);
  final prompt = ref.watch(systemPromptProvider).maybeWhen(
        data: (p) => p,
        orElse: () => 'Du bist der Athlete\'s Mindful Companion.',
      );
  final apiKey = secure.getLlmApiKey();
  return _AsyncLlmEngine(secure: secure, systemPrompt: prompt, apiKey: apiKey);
});

class _AsyncLlmEngine implements LlmEngine {
  _AsyncLlmEngine({required this.secure, required this.systemPrompt, required this.apiKey});
  final SecureStorageService secure;
  final String systemPrompt;
  final Future<String?> apiKey;

  LlmEngine? _resolved;

  Future<LlmEngine> _engine() async {
    if (_resolved != null) return _resolved!;
    final key = await apiKey;
    if (key != null && key.isNotEmpty) {
      _resolved = MistralLlmEngine(apiKey: key);
    } else {
      _resolved = MockLlmEngine();
    }
    return _resolved!;
  }

  @override
  Future<String> respond({
    required context,
    required userInput,
    required history,
  }) => _engine().then((e) => e.respond(context: context, userInput: userInput, history: history));

  @override
  Future<MicroInsight> generateInsight({
    required session,
    required moments,
    required conversation,
  }) =>
      _engine().then((e) => e.generateInsight(session: session, moments: moments, conversation: conversation));
}

final startSessionUseCaseProvider = Provider<StartSession>(
  (ref) => StartSession(ref.watch(sessionRepositoryProvider)),
);
final updateSessionUseCaseProvider = Provider<UpdateSession>(
  (ref) => UpdateSession(ref.watch(sessionRepositoryProvider)),
);
final completeSessionUseCaseProvider = Provider<CompleteSession>(
  (ref) => CompleteSession(ref.watch(sessionRepositoryProvider)),
);
final addKeyMomentUseCaseProvider = Provider<AddKeyMoment>(
  (ref) => AddKeyMoment(ref.watch(sessionRepositoryProvider)),
);
final exportDataProvider = Provider<ExportData>(
  (ref) => ExportData(ref.watch(sessionRepositoryProvider)),
);
