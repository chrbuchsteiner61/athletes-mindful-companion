import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/models.dart';
import '../../providers/archive_notifier.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(archiveProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archiveProvider);
    final detector = ref.read(patternDetectorProvider);
    final open = detector.openMoments(state.moments);
    final trained = detector.trainedMoments(state.moments);
    final success = detector.successMoments(state.moments);

    return Scaffold(
      appBar: AppBar(title: const Text('Gedächtnis-Archiv')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(archiveProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              if (state.patterns.isNotEmpty) ...[
                const _SectionTitle('Muster-Erkennung'),
                ...state.patterns.map((p) => _PatternTile(text: p)),
                const SizedBox(height: 20),
              ],
              const _SectionTitle('Offene Schlüsselmomente'),
              if (open.isEmpty) const _Empty(text: 'Keine offenen Momente.'),
              ...open.map((m) => _MomentTile(moment: m, onResolve: () => ref.read(archiveProvider.notifier).resolveMoment(m.id))),
              const SizedBox(height: 20),
              const _SectionTitle('Trainiert'),
              if (trained.isEmpty) const _Empty(text: 'Noch nichts als trainiert markiert.'),
              ...trained.map((m) => _MomentTile(moment: m, onResolve: null)),
              const SizedBox(height: 20),
              const _SectionTitle('Erfolgszimmer'),
              if (success.isEmpty) const _Empty(text: 'Noch keine Highlights erfasst.'),
              ...success.map((m) => _MomentTile(moment: m, onResolve: null, isHighlight: true)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 1)),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppTheme.muted, fontSize: 14)),
    );
  }
}

class _PatternTile extends StatelessWidget {
  const _PatternTile({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.sand,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat_rounded, size: 18, color: AppTheme.sage),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.ink))),
        ],
      ),
    );
  }
}

class _MomentTile extends StatelessWidget {
  const _MomentTile({required this.moment, required this.onResolve, this.isHighlight = false});
  final KeyMoment moment;
  final VoidCallback? onResolve;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isHighlight ? Icons.emoji_events_outlined : Icons.flag_outlined,
              color: AppTheme.sage, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(moment.description, style: const TextStyle(fontSize: 14, color: AppTheme.ink)),
                if (moment.emotionTriggered != null) ...[
                  const SizedBox(height: 4),
                  Text(moment.emotionTriggered!, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                ],
                if (moment.insight != null) ...[
                  const SizedBox(height: 6),
                  Text(moment.insight!, style: const TextStyle(fontSize: 12, color: AppTheme.sage, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          if (onResolve != null)
            TextButton(onPressed: onResolve, child: const Text('Trainiert', style: TextStyle(color: AppTheme.sage)))
          else if (moment.isResolved)
            const Chip(label: Text('Trainiert'), backgroundColor: AppTheme.sand),
        ],
      ),
    );
  }
}
