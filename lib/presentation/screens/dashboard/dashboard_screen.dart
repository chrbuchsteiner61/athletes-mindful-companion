import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/mental_journey_notifier.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.onStartPreSession, required this.onStartPostSession});

  final VoidCallback onStartPreSession;
  final VoidCallback onStartPostSession;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mentalJourneyProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final journey = ref.watch(mentalJourneyProvider);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(mentalJourneyProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            children: [
              Text('Guten Tag',
                  style: TextStyle(fontSize: 14, color: AppTheme.muted, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              const Text('Dein Sport-Kompass',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.ink)),
              const SizedBox(height: 24),
              _NextImpulseCard(impulse: journey.nextImpulse),
              const SizedBox(height: 16),
              _MentalJourneyCard(trends: journey.trends, summary: journey.insightSummary),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: widget.onStartPreSession,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Starte Pre-Session Check-in'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: widget.onStartPostSession,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Starte Post-Session Reflexion'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.sage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.sage),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextImpulseCard extends StatelessWidget {
  const _NextImpulseCard({required this.impulse});
  final String? impulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt_outlined, color: AppTheme.sage, size: 18),
              SizedBox(width: 6),
              Text('NÄCHSTER TRAININGS-IMPULS',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            impulse ?? 'Noch kein Impuls gesetzt. Starte eine Session, um deinen Fokus zu definieren.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: impulse == null ? AppTheme.muted : AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _MentalJourneyCard extends StatelessWidget {
  const _MentalJourneyCard({required this.trends, required this.summary});
  final List trends;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.show_chart_rounded, color: AppTheme.sage, size: 18),
              SizedBox(width: 6),
              Text('MENTALE REISE (Letzte 5 Einheiten)',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 14),
          if (trends.isEmpty)
            const Text('Sammle Erkenntnisse, um deine mentale Entwicklung zu sehen.',
                style: TextStyle(color: AppTheme.muted, fontSize: 14))
          else
            ...trends.take(3).map((t) => TrendBar(
                  label: t.emotionName as String,
                  percentage: t.percentage as int,
                  delta: t.deltaPercentage as int,
                )),
          if (summary != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.sand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 16, color: AppTheme.sage),
                  const SizedBox(width: 8),
                  Expanded(child: Text(summary!, style: const TextStyle(fontSize: 13, color: AppTheme.ink))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
