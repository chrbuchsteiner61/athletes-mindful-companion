import '../../domain/entities/models.dart';
import '../database/json_store.dart';

class SessionRepository {
  SessionRepository(this._store);
  final JsonStore _store;
  static const String _sessionsKey = 'sessions';
  static const String _momentsKey = 'key_moments';

  Future<List<Session>> getAllSessions() async {
    final rows = await _store.readList(_sessionsKey);
    return rows.map(_sessionFromJson).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<Session?> getLatestSession() async {
    final all = await getAllSessions();
    return all.isEmpty ? null : all.first;
  }

  Future<void> upsertSession(Session session) async {
    final all = await getAllSessions();
    final idx = all.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      all[idx] = session;
    } else {
      all.insert(0, session);
    }
    await _store.writeList(_sessionsKey, all.map(_sessionToJson).toList());
  }

  Future<void> deleteSession(String id) async {
    final all = await getAllSessions();
    all.removeWhere((s) => s.id == id);
    await _store.writeList(_sessionsKey, all.map(_sessionToJson).toList());
    final moments = await getKeyMoments();
    moments.removeWhere((m) => m.sessionId == id);
    await _store.writeList(_momentsKey, moments.map(_keyMomentToJson).toList());
  }

  Future<List<KeyMoment>> getKeyMoments() async {
    final rows = await _store.readList(_momentsKey);
    return rows.map(_keyMomentFromJson).toList();
  }

  Future<List<KeyMoment>> getMomentsForSession(String sessionId) async {
    final all = await getKeyMoments();
    return all.where((m) => m.sessionId == sessionId).toList();
  }

  Future<void> addKeyMoment(KeyMoment moment) async {
    final all = await getKeyMoments();
    all.insert(0, moment);
    await _store.writeList(_momentsKey, all.map(_keyMomentToJson).toList());
  }

  Future<void> resolveKeyMoment(String momentId) async {
    final all = await getKeyMoments();
    final idx = all.indexWhere((m) => m.id == momentId);
    if (idx >= 0) {
      all[idx] = all[idx].copyWith(isResolved: true);
      await _store.writeList(_momentsKey, all.map(_keyMomentToJson).toList());
    }
  }

  Map<String, dynamic> _sessionToJson(Session s) => {
        'id': s.id,
        'timestamp': s.timestamp.toIso8601String(),
        'sport': s.sport.name,
        'isCompetition': s.isCompetition,
        'energyLevelPre': s.energyLevelPre,
        'primaryFocus': s.primaryFocus,
        'targetEmotions': s.targetEmotions,
        'mentalAnchorWords': s.mentalAnchorWords,
        'energyLevelPost': s.energyLevelPost,
        'headline': s.headline,
        'dominantEmotions': s.dominantEmotions,
        'nextActionImpulse': s.nextActionImpulse,
        'status': s.status.name,
        'completedAt': s.completedAt?.toIso8601String(),
      };

  Session _sessionFromJson(Map<String, dynamic> j) => Session(
        id: j['id'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        sport: SportType.values.byName(j['sport'] as String),
        isCompetition: j['isCompetition'] as bool,
        energyLevelPre: (j['energyLevelPre'] as num?)?.toInt(),
        primaryFocus: j['primaryFocus'] as String?,
        targetEmotions: ((j['targetEmotions'] as List?) ?? []).cast<String>(),
        mentalAnchorWords: ((j['mentalAnchorWords'] as List?) ?? []).cast<String>(),
        energyLevelPost: (j['energyLevelPost'] as num?)?.toInt(),
        headline: j['headline'] as String?,
        dominantEmotions: ((j['dominantEmotions'] as List?) ?? []).cast<String>(),
        nextActionImpulse: j['nextActionImpulse'] as String?,
        status: SessionPhase.values.byName(j['status'] as String),
        completedAt: j['completedAt'] == null ? null : DateTime.parse(j['completedAt'] as String),
      );

  Map<String, dynamic> _keyMomentToJson(KeyMoment m) => {
        'id': m.id,
        'sessionId': m.sessionId,
        'type': m.type.name,
        'description': m.description,
        'emotionTriggered': m.emotionTriggered,
        'insight': m.insight,
        'isResolved': m.isResolved,
        'createdAt': m.createdAt?.toIso8601String(),
      };

  KeyMoment _keyMomentFromJson(Map<String, dynamic> j) => KeyMoment(
        id: j['id'] as String,
        sessionId: j['sessionId'] as String,
        type: MomentType.values.byName(j['type'] as String),
        description: j['description'] as String,
        emotionTriggered: j['emotionTriggered'] as String?,
        insight: j['insight'] as String?,
        isResolved: j['isResolved'] as bool? ?? false,
        createdAt: j['createdAt'] == null ? null : DateTime.parse(j['createdAt'] as String),
      );
}
