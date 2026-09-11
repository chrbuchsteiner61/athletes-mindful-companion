import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../domain/entities/models.dart';
import '../../data/repositories/session_repository.dart';

class StartSession {
  StartSession(this._repo);
  final SessionRepository _repo;
  final _uuid = const Uuid();

  Future<Session> call({required SportType sport, required bool isCompetition}) async {
    final session = Session(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      sport: sport,
      isCompetition: isCompetition,
      status: SessionPhase.preSession,
    );
    await _repo.upsertSession(session);
    return session;
  }
}

class UpdateSession {
  UpdateSession(this._repo);
  final SessionRepository _repo;

  Future<Session> call(Session session) async {
    final updated = session.copyWith();
    await _repo.upsertSession(updated);
    return updated;
  }
}

class CompleteSession {
  CompleteSession(this._repo);
  final SessionRepository _repo;

  Future<Session> call(Session session) async {
    final completed = session.copyWith(
      status: SessionPhase.completed,
      completedAt: DateTime.now(),
    );
    await _repo.upsertSession(completed);
    return completed;
  }
}

class AddKeyMoment {
  AddKeyMoment(this._repo);
  final SessionRepository _repo;
  final _uuid = const Uuid();

  Future<KeyMoment> call({
    required String sessionId,
    required MomentType type,
    required String description,
    String? emotionTriggered,
    String? insight,
  }) async {
    final moment = KeyMoment(
      id: _uuid.v4(),
      sessionId: sessionId,
      type: type,
      description: description,
      emotionTriggered: emotionTriggered,
      insight: insight,
      createdAt: DateTime.now(),
    );
    await _repo.addKeyMoment(moment);
    return moment;
  }
}

class ExportData {
  ExportData(this._repo);
  final SessionRepository _repo;

  Future<String> asJson() async {
    final sessions = await _repo.getAllSessions();
    final moments = await _repo.getKeyMoments();
    final map = {
      'sessions': sessions.map(_s).toList(),
      'keyMoments': moments.map(_m).toList(),
    };
    return _encode(map);
  }

  Future<String> asCsv() async {
    final sessions = await _repo.getAllSessions();
    final header = 'date,sport,competition,energyPre,energyPost,headline,emotions,impulse,status';
    final rows = sessions.map((s) {
      return [
        s.timestamp.toIso8601String(),
        s.sport.name,
        s.isCompetition ? '1' : '0',
        s.energyLevelPre?.toString() ?? '',
        s.energyLevelPost?.toString() ?? '',
        _csv(s.headline),
        _csv(s.dominantEmotions.join('|')),
        _csv(s.nextActionImpulse),
        s.status.name,
      ].join(',');
    }).toList();
    return [header, ...rows].join('\n');
  }

  String _csv(String? v) {
    if (v == null) return '';
    if (v.contains(',') || v.contains('"')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  Map<String, dynamic> _s(Session s) => {
        'id': s.id,
        'timestamp': s.timestamp.toIso8601String(),
        'sport': s.sport.name,
        'isCompetition': s.isCompetition,
        'energyLevelPre': s.energyLevelPre,
        'primaryFocus': s.primaryFocus,
        'dominantEmotions': s.dominantEmotions,
        'headline': s.headline,
        'nextActionImpulse': s.nextActionImpulse,
        'status': s.status.name,
      };

  Map<String, dynamic> _m(KeyMoment m) => {
        'id': m.id,
        'sessionId': m.sessionId,
        'type': m.type.name,
        'description': m.description,
        'emotionTriggered': m.emotionTriggered,
        'isResolved': m.isResolved,
      };

  String _encode(Map<String, dynamic> m) {
    return const JsonEncoder.withIndent('  ').convert(m);
  }
}
