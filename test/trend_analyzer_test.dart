import 'package:flutter_test/flutter_test.dart';
import 'package:athletes_mindful_companion/domain/entities/models.dart';
import 'package:athletes_mindful_companion/domain/services/trend_analyzer.dart';

void main() {
  group('TrendAnalyzer', () {
    final analyzer = TrendAnalyzer();

    test('returns empty for no sessions', () {
      expect(analyzer.analyzeTrends([]), isEmpty);
    });

    test('aggregates dominant emotions across sessions', () {
      final now = DateTime.now();
      final sessions = [
        Session(
          id: '1',
          timestamp: now,
          sport: SportType.golf,
          isCompetition: false,
          dominantEmotions: ['Frust', 'Angst'],
          targetEmotions: ['Gelassenheit'],
        ),
        Session(
          id: '2',
          timestamp: now,
          sport: SportType.golf,
          isCompetition: false,
          dominantEmotions: ['Frust'],
          targetEmotions: ['Gelassenheit', 'Fokus'],
        ),
      ];
      final trends = analyzer.analyzeTrends(sessions, window: 5);
      final frust = trends.firstWhere((t) => t.emotionName == 'Frust');
      expect(frust.occurrenceCount, 2);
      expect(trends.first.percentage, greaterThan(0));
    });

    test('generates insight summary for top trend', () {
      final now = DateTime.now();
      final sessions = [
        Session(
          id: '1',
          timestamp: now,
          sport: SportType.tennis,
          isCompetition: true,
          dominantEmotions: ['Gelassenheit'],
        ),
      ];
      final trends = analyzer.analyzeTrends(sessions);
      final summary = analyzer.generateInsightSummary(trends);
      expect(summary, isNotNull);
      expect(summary, contains('Gelassenheit'));
    });
  });

  group('PatternDetector', () {
    final detector = PatternDetector();

    test('detects recurring triggers', () {
      final now = DateTime.now();
      final moments = [
        KeyMoment(
          id: 'a', sessionId: 's1', type: MomentType.learningMoment,
          description: 'Bahn 8 Wasser', emotionTriggered: 'Angst vor Wasser',
          createdAt: now,
        ),
        KeyMoment(
          id: 'b', sessionId: 's2', type: MomentType.learningMoment,
          description: 'Bahn 8 erneut', emotionTriggered: 'Angst vor Wasser',
          createdAt: now,
        ),
        KeyMoment(
          id: 'c', sessionId: 's3', type: MomentType.learningMoment,
          description: 'Eintags', emotionTriggered: 'Ungeduld',
          createdAt: now,
        ),
      ];
      final patterns = detector.detectRecurringTriggers(moments);
      expect(patterns.any((p) => p.contains('Angst vor Wasser')), isTrue);
      expect(patterns.any((p) => p.contains('Ungeduld')), isFalse);
    });

    test('splits open vs trained moments', () {
      final moments = [
        const KeyMoment(id: 'a', sessionId: 's', type: MomentType.learningMoment, description: 'x'),
        const KeyMoment(id: 'b', sessionId: 's', type: MomentType.highlight, description: 'y', isResolved: true),
      ];
      expect(detector.openMoments(moments).length, 1);
      expect(detector.trainedMoments(moments).length, 1);
      expect(detector.successMoments(moments).length, 1);
    });
  });
}
