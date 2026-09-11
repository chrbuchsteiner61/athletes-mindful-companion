import '../../domain/entities/models.dart';
import '../services/context_assembler.dart';

abstract class LlmEngine {
  Future<String> respond({
    required CoachContext context,
    required String userInput,
    required List<ChatMessage> history,
  });

  Future<MicroInsight> generateInsight({
    required Session session,
    required List<KeyMoment> moments,
    required List<ChatMessage> conversation,
  });
}

class MicroInsight {
  const MicroInsight({
    required this.insight,
    required this.impulse,
  });
  final String insight;
  final String impulse;
}
