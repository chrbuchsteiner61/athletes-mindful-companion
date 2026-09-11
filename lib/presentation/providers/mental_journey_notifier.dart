import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/models.dart';
import '../providers/providers.dart';

class MentalJourneyState {
  const MentalJourneyState({
    this.sessions = const [],
    this.trends = const [],
    this.nextImpulse,
    this.insightSummary,
    this.isLoading = false,
  });

  final List<Session> sessions;
  final List<MentalTrend> trends;
  final String? nextImpulse;
  final String? insightSummary;
  final bool isLoading;

  MentalJourneyState copyWith({
    List<Session>? sessions,
    List<MentalTrend>? trends,
    String? nextImpulse,
    String? insightSummary,
    bool? isLoading,
  }) {
    return MentalJourneyState(
      sessions: sessions ?? this.sessions,
      trends: trends ?? this.trends,
      nextImpulse: nextImpulse ?? this.nextImpulse,
      insightSummary: insightSummary ?? this.insightSummary,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MentalJourneyNotifier extends StateNotifier<MentalJourneyState> {
  MentalJourneyNotifier(this._ref) : super(const MentalJourneyState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(sessionRepositoryProvider);
    final sessions = await repo.getAllSessions();
    final trends = _ref.read(trendAnalyzerProvider).analyzeTrends(sessions);
    final insight = _ref.read(trendAnalyzerProvider).generateInsightSummary(trends);
    final withImpulse = sessions
        .where((s) => s.nextActionImpulse != null && s.nextActionImpulse!.isNotEmpty)
        .toList();
    final nextImpulse = withImpulse.isEmpty ? null : withImpulse.first.nextActionImpulse;
    state = MentalJourneyState(
      sessions: sessions,
      trends: trends,
      nextImpulse: nextImpulse,
      insightSummary: insight,
      isLoading: false,
    );
  }
}

final mentalJourneyProvider =
    StateNotifierProvider<MentalJourneyNotifier, MentalJourneyState>(
  (ref) => MentalJourneyNotifier(ref),
);
