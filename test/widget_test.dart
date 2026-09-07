import 'package:athletes_mindful_companion/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the session screen by default', (tester) async {
    await tester.pumpWidget(const AthletesMindfulCompanionApp());

    expect(find.text("Today's session"), findsWidgets);
    expect(find.text('Start session'), findsOneWidget);
  });
}