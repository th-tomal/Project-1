// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:app/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  // Build our app and trigger a frame.
  // The project app uses `SmartCoachApp` (login screen) instead of the
  // default template `MyApp` with a counter. Update the test accordingly.
  await tester.pumpWidget(SmartCoachApp());

  // Verify that the login/title text from `LoginScreen` is shown.
  expect(find.text('SmartCoach'), findsOneWidget);
  });
}
