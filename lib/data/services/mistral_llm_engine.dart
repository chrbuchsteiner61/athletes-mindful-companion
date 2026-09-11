import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/models.dart';
import 'llm_engine.dart';
import '../services/context_assembler.dart';

class MistralLlmEngine implements LlmEngine {
  MistralLlmEngine({
    required String apiKey,
    String model = 'mistral-small-latest',
    String endpoint = 'https://api.mistral.ai/v1/chat/completions',
    http.Client? client,
  })  : _apiKey = apiKey,
        _model = model,
        _endpoint = endpoint,
        _client = client ?? http.Client();

  final String _apiKey;
  final String _model;
  final String _endpoint;
  final http.Client _client;

  @override
  Future<String> respond({
    required CoachContext context,
    required String userInput,
    required List<ChatMessage> history,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': context.systemPrompt},
    ];
    for (final m in history) {
      messages.add({
        'role': m.role == ChatRole.user ? 'user' : 'assistant',
        'content': m.content,
      });
    }
    messages.add({
      'role': 'user',
      'content':
          '${_buildContextBlock(context)}\n\nNutzer: $userInput',
    });

    final body = jsonEncode({
      'model': _model,
      'messages': messages,
      'temperature': 0.6,
      'max_tokens': 220,
    });

    final res = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (res.statusCode != 200) {
      throw Exception('Mistral API Fehler ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = data['choices'] as List;
    return (choices.first['message']['content'] as String).trim();
  }

  @override
  Future<MicroInsight> generateInsight({
    required Session session,
    required List<KeyMoment> moments,
    required List<ChatMessage> conversation,
  }) async {
    final transcript = conversation.map((m) {
      final who = m.role == ChatRole.user ? 'Nutzer' : 'Coach';
      return '$who: ${m.content}';
    }).join('\n');
    final momentText = moments.isEmpty
        ? '(keine Schlüsselmomente erfasst)'
        : moments.map((m) => '- ${m.description} (${m.emotionTriggered ?? "-"})').join('\n');

    final prompt = '''
Fasse den Reflexionsdialog zu einer Micro-Insight-Karte zusammen. Antworte NUR als JSON mit den Feldern "insight" und "impulse".
- insight: eine prägnante Erkenntnis (1-2 Sätze), wertfrei, fokussiert auf Gefühl/Verhalten, nicht auf Ergebnis.
- impulse: EIN konkreter, selbstbestimmter Trainingsimpuls für die nächste Einheit.

Session: ${session.sport.name} (${session.isCompetition ? "Wettkampf" : "Training"})
Schlagzeile: ${session.headline ?? "-"}
Dominante Emotionen: ${session.dominantEmotions.join(", ")}
Fokus: ${session.primaryFocus ?? "-"}
Schlüsselmomente:
$momentText

Dialog:
$transcript
''';

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': context_systemFallback},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.4,
      'max_tokens': 220,
      'response_format': {'type': 'json_object'},
    });

    final res = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (res.statusCode != 200) {
      throw Exception('Mistral API Fehler ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final content = (data['choices'] as List).first['message']['content'] as String;
    try {
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      return MicroInsight(
        insight: parsed['insight'] as String? ?? '',
        impulse: parsed['impulse'] as String? ?? '',
      );
    } catch (_) {
      return MicroInsight(insight: content, impulse: session.nextActionImpulse ?? '');
    }
  }

  String _buildContextBlock(CoachContext ctx) {
    final b = StringBuffer();
    b.writeln('Phase: ${ctx.phase.name}');
    b.writeln('Sport: ${ctx.session.sport.name}');
    if (ctx.session.dominantEmotions.isNotEmpty) {
      b.writeln('Emotionen: ${ctx.session.dominantEmotions.join(", ")}');
    }
    if (ctx.session.primaryFocus != null) b.writeln('Fokus: ${ctx.session.primaryFocus}');
    if (ctx.recentSessions.isNotEmpty) {
      b.writeln('Letzte Sessions:');
      for (final s in ctx.recentSessions) {
        b.writeln('  - ${s.dominantEmotions.join("/")} | Impuls: ${s.nextActionImpulse ?? "-"}');
      }
    }
    return b.toString();
  }

  static const String context_systemFallback =
      'Du bist der Athlete\'s Mindful Companion. Antworte wertfrei, sportbezogen und als JSON.';
}
