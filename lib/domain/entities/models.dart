import 'package:equatable/equatable.dart';

enum SportType { golf, tennis, running, general }

enum SessionPhase { preSession, active, postSession, completed }

enum MomentType { highlight, learningMoment }

class Session extends Equatable {
  const Session({
    required this.id,
    required this.timestamp,
    required this.sport,
    required this.isCompetition,
    this.energyLevelPre,
    this.primaryFocus,
    this.targetEmotions = const [],
    this.energyLevelPost,
    this.headline,
    this.dominantEmotions = const [],
    this.nextActionImpulse,
    this.mentalAnchorWords = const [],
    this.status = SessionPhase.preSession,
    this.completedAt,
  });

  final String id;
  final DateTime timestamp;
  final SportType sport;
  final bool isCompetition;

  final int? energyLevelPre;
  final String? primaryFocus;
  final List<String> targetEmotions;
  final List<String> mentalAnchorWords;

  final int? energyLevelPost;
  final String? headline;
  final List<String> dominantEmotions;

  final String? nextActionImpulse;
  final SessionPhase status;
  final DateTime? completedAt;

  Session copyWith({
    String? id,
    DateTime? timestamp,
    SportType? sport,
    bool? isCompetition,
    int? energyLevelPre,
    String? primaryFocus,
    List<String>? targetEmotions,
    List<String>? mentalAnchorWords,
    int? energyLevelPost,
    String? headline,
    List<String>? dominantEmotions,
    String? nextActionImpulse,
    SessionPhase? status,
    DateTime? completedAt,
  }) {
    return Session(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      sport: sport ?? this.sport,
      isCompetition: isCompetition ?? this.isCompetition,
      energyLevelPre: energyLevelPre ?? this.energyLevelPre,
      primaryFocus: primaryFocus ?? this.primaryFocus,
      targetEmotions: targetEmotions ?? this.targetEmotions,
      mentalAnchorWords: mentalAnchorWords ?? this.mentalAnchorWords,
      energyLevelPost: energyLevelPost ?? this.energyLevelPost,
      headline: headline ?? this.headline,
      dominantEmotions: dominantEmotions ?? this.dominantEmotions,
      nextActionImpulse: nextActionImpulse ?? this.nextActionImpulse,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, timestamp, sport, isCompetition, energyLevelPre, primaryFocus,
        targetEmotions, mentalAnchorWords, energyLevelPost, headline,
        dominantEmotions, nextActionImpulse, status, completedAt,
      ];
}

class KeyMoment extends Equatable {
  const KeyMoment({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.description,
    this.emotionTriggered,
    this.insight,
    this.isResolved = false,
    this.createdAt,
  });

  final String id;
  final String sessionId;
  final MomentType type;
  final String description;
  final String? emotionTriggered;
  final String? insight;
  final bool isResolved;
  final DateTime? createdAt;

  KeyMoment copyWith({
    String? id,
    String? sessionId,
    MomentType? type,
    String? description,
    String? emotionTriggered,
    String? insight,
    bool? isResolved,
    DateTime? createdAt,
  }) {
    return KeyMoment(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      description: description ?? this.description,
      emotionTriggered: emotionTriggered ?? this.emotionTriggered,
      insight: insight ?? this.insight,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, sessionId, type, description, emotionTriggered, insight, isResolved, createdAt,
      ];
}

class MentalTrend extends Equatable {
  const MentalTrend({
    required this.emotionName,
    required this.occurrenceCount,
    this.associatedTriggers = const [],
    this.percentage = 0,
    this.deltaPercentage = 0,
  });

  final String emotionName;
  final int occurrenceCount;
  final List<String> associatedTriggers;
  final int percentage;
  final int deltaPercentage;

  @override
  List<Object?> get props => [emotionName, occurrenceCount, associatedTriggers, percentage, deltaPercentage];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.timestamp,
    this.quickReplies = const [],
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime? timestamp;
  final List<String> quickReplies;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? timestamp,
    List<String>? quickReplies,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      quickReplies: quickReplies ?? this.quickReplies,
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, quickReplies];
}

enum ChatRole { user, coach }
