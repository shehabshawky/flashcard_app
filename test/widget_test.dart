import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcard_app/core/di/service_locator.dart';
import 'package:flashcard_app/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  testWidgets('Clean Architecture Flashcard study app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlashcardApp());
    await tester.pumpAndSettle();

    // Verify title is rendered
    expect(find.text('FlashStudy'), findsOneWidget);

    // Initial card progress
    expect(find.text('1 / 5'), findsOneWidget);

    // Check front face has QUESTION badge and "Show Answer"
    expect(find.text('QUESTION'), findsOneWidget);
    expect(find.text('Show Answer'), findsOneWidget);

    // Tap "Show Answer" to flip the card
    await tester.tap(find.text('Show Answer'));
    await tester.pumpAndSettle();

    // Check back face reveals ANSWER badge and "Hide Answer"
    expect(find.text('ANSWER'), findsOneWidget);
    expect(find.text('Hide Answer'), findsOneWidget);

    // Tap "Next" button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify moved to Card 2
    expect(find.text('2 / 5'), findsOneWidget);
    expect(find.text('QUESTION'), findsOneWidget);
  });
}
