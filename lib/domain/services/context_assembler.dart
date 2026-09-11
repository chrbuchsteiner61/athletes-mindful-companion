import '../../domain/entities/models.dart';

class CoachContext {
  const CoachContext({
    required this.systemPrompt,
    required this.session,
    required this.recentSessions,
    required this.phase,
    this.quickReplies = const [],
  });

  final String systemPrompt;
  final Session session;
  final List<Session> recentSessions;
  final SessionPhase phase;
  final List<String> quickReplies;
}

class ContextAssembler {
  ContextAssembler(this._systemPrompt);
  final String _systemPrompt;

  CoachContext assemble({
    required Session session,
    required List<Session> history,
    required List<ChatMessage> conversation,
  }) {
    final recent = history.where((s) => s.id != session.id).take(3).toList();
    final phase = session.status;

    final chips = _quickRepliesForPhase(phase, session);
    return CoachContext(
      systemPrompt: _systemPrompt,
      session: session,
      recentSessions: recent,
      phase: phase,
      quickReplies: chips,
    );
  }

  String buildPrompt(CoachContext ctx, String userInput) {
    final buffer = StringBuffer();
    buffer.writeln('Phase: ${_phaseName(ctx.phase)}');
    buffer.writeln(
        'Sport: ${_sportName(ctx.session.sport)} (${ctx.session.isCompetition ? "Wettkampf" : "Training"})');
    if (ctx.session.energyLevelPre != null) {
      buffer.writeln('Energie vorher: ${ctx.session.energyLevelPre}/10');
    }
    if (ctx.session.energyLevelPost != null) {
      buffer.writeln('Energie nachher: ${ctx.session.energyLevelPost}/10');
    }
    if (ctx.session.primaryFocus != null) {
      buffer.writeln('Fokus: ${ctx.session.primaryFocus}');
    }
    if (ctx.session.mentalAnchorWords.isNotEmpty) {
      buffer.writeln('Anker-Worte: ${ctx.session.mentalAnchorWords.join(", ")}');
    }
    if (ctx.session.dominantEmotions.isNotEmpty) {
      buffer.writeln('Dominante Emotionen: ${ctx.session.dominantEmotions.join(", ")}');
    }
    if (ctx.session.headline != null) {
      buffer.writeln('Schlagzeile: ${ctx.session.headline}');
    }
    if (ctx.session.nextActionImpulse != null) {
      buffer.writeln('Letzter Impuls: ${ctx.session.nextActionImpulse}');
    }
    if (ctx.recentSessions.isNotEmpty) {
      buffer.writeln('Letzte Sessions:');
      for (final s in ctx.recentSessions) {
        buffer.writeln(
            '  - ${s.timestamp.toIso8601String().substring(0, 10)}: ${s.dominantEmotions.join("/")} | Impuls: ${s.nextActionImpulse ?? "-"}');
      }
    }
    buffer.writeln('\nNutzer: $userInput');
    buffer.writeln('Coach:');
    return buffer.toString();
  }

  List<String> _quickRepliesForPhase(SessionPhase phase, Session session) {
    switch (phase) {
      case SessionPhase.preSession:
        return const ['Pre-Shot Routine einhalten', 'Fehler schnell abhaken', 'Rhythmus halten'];
      case SessionPhase.active:
        return const ['Frust', 'Fokus verloren', 'Flow-Moment', 'Routine übersprungen'];
      case SessionPhase.postSession:
      case SessionPhase.completed:
        return const ['Neugier', 'Angst / Unsicherheit', 'Frust', 'Stolz', 'Ungeduld', 'Gelassenheit'];
    }
  }

  String _phaseName(SessionPhase p) => switch (p) {
        SessionPhase.preSession => 'Vorbereitung',
        SessionPhase.active => 'Durchführung',
        SessionPhase.postSession => 'Reflexion',
        SessionPhase.completed => 'Transfer',
      };

  String _sportName(SportType s) => switch (s) {
        SportType.golf => 'Golf',
        SportType.tennis => 'Tennis',
        SportType.running => 'Laufen',
        SportType.general => 'Allgemein',
      };
}
