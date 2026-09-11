import '../../domain/entities/models.dart';
import '../../domain/services/context_assembler.dart';
import '../../domain/services/llm_engine.dart';

/// Offline-Fallback-Engine. Nutzt phasenbasierte Reflexionsfragen und generiert
/// eine deterministische Micro-Insight-Karte, falls keine LLM-API verfügbar ist.
class MockLlmEngine implements LlmEngine {
  @override
  Future<String> respond({
    required CoachContext context,
    required String userInput,
    required List<ChatMessage> history,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _phaseReply(context, history, userInput);
  }

  String _phaseReply(CoachContext ctx, List<ChatMessage> history, String input) {
    switch (ctx.phase) {
      case SessionPhase.preSession:
        if (ctx.session.energyLevelPre == null) {
          return 'Willkommen! Lass uns deinen Kopf klar ausrichten. Wie steht es um deine Energie auf einer Skala von 1 bis 10?';
        }
        if (ctx.session.primaryFocus == null) {
          return 'Gut, eine solide Basis. Auf welchen einzigen Fokusschwerpunkt möchtest du dich heute konzentrieren?';
        }
        if (ctx.session.mentalAnchorWords.isEmpty) {
          return 'Verstanden. Mit welchen 2 Worten beschreibst du das Gefühl, das du heute verkörpern willst?';
        }
        return 'Perfekt. Merk dir diese Worte: ${ctx.session.mentalAnchorWords.join(" und ")}. '
            'Es geht heute nicht um den Score, sondern um deinen Prozess. Viel Erfolg!';
      case SessionPhase.active:
        return 'Notiz gespeichert. Wir analysieren das nachher in Ruhe. Fokus zurück auf den nächsten Schritt!';
      case SessionPhase.postSession:
      case SessionPhase.completed:
        if (ctx.session.headline == null) {
          return 'Willkommen zurück. Lass den Schläger ruhen. Wenn du deine Session in einem Satz beschreiben müsstest – wie lautet deine Schlagzeile?';
        }
        if (ctx.session.dominantEmotions.isEmpty) {
          return 'Danke. Welche 2 Haupt-Emotionen haben dich am stärksten begleitet?';
        }
        return 'Danke für deine Ehrigkeit. Was war der eigentliche Auslöser dafür? Was ging in dem Moment in deinem Kopf vor?';
    }
  }

  @override
  Future<MicroInsight> generateInsight({
    required Session session,
    required List<KeyMoment> moments,
    required List<ChatMessage> conversation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final userMessages = conversation.where((m) => m.role == ChatRole.user).toList();
    final trigger = moments.isNotEmpty
        ? moments.first.emotionTriggered ?? moments.first.description
        : (session.dominantEmotions.isNotEmpty ? session.dominantEmotions.first : 'eine Situation');

    final insight = 'Auslöser (${trigger}) führte zu verändertem Verhalten. '
        'Wenn du an deiner Routine bleibst, bleibst du bei dir.';
    final impulse = userMessages.isNotEmpty && userMessages.any((m) => m.content.toLowerCase().contains('range'))
        ? '5 Abschläge auf der Range mit Zielzone – jeder Schlag mit voller Pre-Shot Routine.'
        : session.nextActionImpulse ?? 'Nimm dir 5 Minuten für deine Routine unter simuliertem Druck.';

    return MicroInsight(insight: insight, impulse: impulse);
  }
}
