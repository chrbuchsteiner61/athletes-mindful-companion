import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'session.g.dart';

/// Sport types supported by the app
enum SportType {
  golf,
  tennis,
  running,
  general,
}

/// Phases of a training/competition session
enum SessionPhase {
  preSession,
  active,
  postSession,
  completed,
}

/// Session entity representing a training or competition unit
@collection
class Session {
  Session({
    String? id,
    required this.timestamp,
    required this.sport,
    this.isCompetition = false,
    this.energyLevelPre = 5,
    this.primaryFocus = '',
    this.targetEmotions = const [],
    this.energyLevelPost = 5,
    this.headline = '',
    this.dominantEmotions = const [],
    this.nextActionImpulse = '',
    this.status = SessionPhase.preSession,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final DateTime timestamp;
  final SportType sport;
  final bool isCompetition;

  // Phase 1: Pre-Session
  final int energyLevelPre; // 1-10
  final String primaryFocus;
  final List<String> targetEmotions;

  // Phase 3: Post-Session Reflexion
  final int energyLevelPost; // 1-10
  final String headline;
  final List<String> dominantEmotions;

  // Phase 4: Transfer
  final String nextActionImpulse;

  @enumerated
  final SessionPhase status;

  // Relationships
  final keyMoments = IsarLinks<KeyMoment>();

  // Helper methods
  bool get isTraining => !isCompetition;
  String get sportDisplayName {
    switch (sport) {
      case SportType.golf:
        return 'Golf';
      case SportType.tennis:
        return 'Tennis';
      case SportType.running:
        return 'Laufen';
      case SportType.general:
        return 'Allgemein';
    }
  }

  Session copyWith({
    String? id,
    DateTime? timestamp,
    SportType? sport,
    bool? isCompetition,
    int? energyLevelPre,
    String? primaryFocus,
    List<String>? targetEmotions,
    int? energyLevelPost,
    String? headline,
    List<String>? dominantEmotions,
    String? nextActionImpulse,
    SessionPhase? status,
  }) {
    return Session(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      sport: sport ?? this.sport,
      isCompetition: isCompetition ?? this.isCompetition,
      energyLevelPre: energyLevelPre ?? this.energyLevelPre,
      primaryFocus: primaryFocus ?? this.primaryFocus,
      targetEmotions: targetEmotions ?? this.targetEmotions,
      energyLevelPost: energyLevelPost ?? this.energyLevelPost,
      headline: headline ?? this.headline,
      dominantEmotions: dominantEmotions ?? this.dominantEmotions,
      nextActionImpulse: nextActionImpulse ?? this.nextActionImpulse,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'sport': sport.name,
      'isCompetition': isCompetition,
      'energyLevelPre': energyLevelPre,
      'primaryFocus': primaryFocus,
      'targetEmotions': targetEmotions,
      'energyLevelPost': energyLevelPost,
      'headline': headline,
      'dominantEmotions': dominantEmotions,
      'nextActionImpulse': nextActionImpulse,
      'status': status.name,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sport: SportType.values.byName(json['sport'] as String),
      isCompetition: json['isCompetition'] as bool? ?? false,
      energyLevelPre: json['energyLevelPre'] as int? ?? 5,
      primaryFocus: json['primaryFocus'] as String? ?? '',
      targetEmotions: (json['targetEmotions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      energyLevelPost: json['energyLevelPost'] as int? ?? 5,
      headline: json['headline'] as String? ?? '',
      dominantEmotions: (json['dominantEmotions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      nextActionImpulse: json['nextActionImpulse'] as String? ?? '',
      status: SessionPhase.values.byName(json['status'] as String),
    );
  }
}

/// Types of key moments (highlights or learning moments)
enum MomentType {
  highlight,
  learningMoment,
}

/// Key moment entity representing a crucial situation during a session
@collection
class KeyMoment {
  KeyMoment({
    String? id,
    required this.sessionId,
    required this.type,
    required this.description,
    this.emotionTriggered = '',
    this.insight = '',
    this.isResolved = false,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String sessionId;

  @enumerated
  final MomentType type;

  final String description;
  final String emotionTriggered;
  final String insight;
  final bool isResolved;

  KeyMoment copyWith({
    String? id,
    String? sessionId,
    MomentType? type,
    String? description,
    String? emotionTriggered,
    String? insight,
    bool? isResolved,
  }) {
    return KeyMoment(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      description: description ?? this.description,
      emotionTriggered: emotionTriggered ?? this.emotionTriggered,
      insight: insight ?? this.insight,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

/// Mental trend entity for aggregating emotional patterns
@collection
class MentalTrend {
  MentalTrend({
    String? id,
    required this.emotionName,
    this.occurrenceCount = 0,
    this.associatedTriggers = const [],
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String emotionName;
  final int occurrenceCount;
  final List<String> associatedTriggers;

  MentalTrend copyWith({
    String? id,
    String? emotionName,
    int? occurrenceCount,
    List<String>? associatedTriggers,
  }) {
    return MentalTrend(
      id: id ?? this.id,
      emotionName: emotionName ?? this.emotionName,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      associatedTriggers: associatedTriggers ?? this.associatedTriggers,
    );
  }
}