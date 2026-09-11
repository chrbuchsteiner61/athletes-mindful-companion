import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/models.dart';
import '../providers/providers.dart';

class ArchiveState {
  const ArchiveState({
    this.moments = const [],
    this.patterns = const [],
    this.isLoading = false,
  });

  final List<KeyMoment> moments;
  final List<String> patterns;
  final bool isLoading;

  ArchiveState copyWith({
    List<KeyMoment>? moments,
    List<String>? patterns,
    bool? isLoading,
  }) {
    return ArchiveState(
      moments: moments ?? this.moments,
      patterns: patterns ?? this.patterns,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ArchiveNotifier extends StateNotifier<ArchiveState> {
  ArchiveNotifier(this._ref) : super(const ArchiveState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final moments = await _ref.read(sessionRepositoryProvider).getKeyMoments();
    final patterns = _ref.read(patternDetectorProvider).detectRecurringTriggers(moments);
    state = ArchiveState(moments: moments, patterns: patterns, isLoading: false);
  }

  Future<void> resolveMoment(String id) async {
    await _ref.read(sessionRepositoryProvider).resolveKeyMoment(id);
    await load();
  }
}

final archiveProvider = StateNotifierProvider<ArchiveNotifier, ArchiveState>(
  (ref) => ArchiveNotifier(ref),
);
