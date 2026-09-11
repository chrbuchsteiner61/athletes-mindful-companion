import '../../domain/entities/models.dart';

class TrendAnalyzer {
  List<MentalTrend> analyzeTrends(List<Session> sessions, {int window = 5}) {
    final recent = sessions.take(window).toList();
    if (recent.isEmpty) return [];

    final emotionCount = <String, int>{};
    final emotionTriggers = <String, Set<String>>{};

    for (final s in recent) {
      for (final e in s.dominantEmotions) {
        emotionCount[e] = (emotionCount[e] ?? 0) + 1;
      }
      for (final e in s.targetEmotions) {
        emotionCount[e] = (emotionCount[e] ?? 0) + 1;
      }
      if (s.primaryFocus != null) {
        for (final e in s.dominantEmotions) {
          emotionTriggers.putIfAbsent(e, () => <String>{}).add(s.primaryFocus!);
        }
      }
    }

    final total = emotionCount.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return [];

    final previous = sessions.skip(window).take(window).toList();
    final prevCount = <String, int>{};
    for (final s in previous) {
      for (final e in s.dominantEmotions) {
        prevCount[e] = (prevCount[e] ?? 0) + 1;
      }
      for (final e in s.targetEmotions) {
        prevCount[e] = (prevCount[e] ?? 0) + 1;
      }
    }
    final prevTotal = prevCount.values.fold<int>(0, (a, b) => a + b) == 0
        ? 1
        : prevCount.values.fold<int>(0, (a, b) => a + b);

    final trends = <MentalTrend>[];
    emotionCount.forEach((emotion, count) {
      final percentage = ((count / total) * 100).round();
      final prevPct = ((prevCount[emotion] ?? 0) / prevTotal * 100).round();
      trends.add(MentalTrend(
        emotionName: emotion,
        occurrenceCount: count,
        associatedTriggers: emotionTriggers[emotion]?.toList() ?? [],
        percentage: percentage,
        deltaPercentage: percentage - prevPct,
      ));
    });

    trends.sort((a, b) => b.percentage.compareTo(a.percentage));
    return trends;
  }

  String? generateInsightSummary(List<MentalTrend> trends) {
    if (trends.isEmpty) return null;
    final top = trends.first;
    final dir = top.deltaPercentage > 0 ? 'steigt' : (top.deltaPercentage < 0 ? 'sinkt' : 'bleibt stabil');
    return 'Deine ${top.emotionName} $dir (${top.percentageText}).';
  }
}

extension on MentalTrend {
  String get percentageText => '$percentage% (${deltaPercentage >= 0 ? '+' : ''}$deltaPercentage%)';
}

class PatternDetector {
  List<String> detectRecurringTriggers(List<KeyMoment> moments, {int window = 5}) {
    final recent = moments.where((m) {
      final created = m.createdAt ?? DateTime.now();
      return created.isAfter(DateTime.now().subtract(const Duration(days: 30)));
    }).toList();

    final triggerCount = <String, int>{};
    for (final m in recent) {
      if (m.emotionTriggered != null && m.emotionTriggered!.isNotEmpty) {
        triggerCount[m.emotionTriggered!] = (triggerCount[m.emotionTriggered!] ?? 0) + 1;
      }
    }

    final recurring = <String>[];
    triggerCount.forEach((trigger, count) {
      if (count >= 2) {
        recurring.add('Muster erkannt: "$trigger" trat $count-mal in letzter Zeit auf.');
      }
    });
    return recurring;
  }

  List<KeyMoment> openMoments(List<KeyMoment> moments) =>
      moments.where((m) => !m.isResolved).toList();

  List<KeyMoment> trainedMoments(List<KeyMoment> moments) =>
      moments.where((m) => m.isResolved).toList();

  List<KeyMoment> successMoments(List<KeyMoment> moments) =>
      moments.where((m) => m.type == MomentType.highlight).toList();
}
