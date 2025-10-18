// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:citizenship_quiz_app/app.dart';

void main() {
  testWidgets('App renders HomeScreen with title', (WidgetTester tester) async {
    // Initialize shared preferences to bypass initial setup.
    SharedPreferences.setMockInitialValues(<String, Object>{
      'selectedStateCode': 'BW',
      'locale': 'de',
    });

    // Build the app.
    await tester.pumpWidget(const App());
    // Let initial animations settle a bit without waiting for infinite spinners.
    await tester.pump(const Duration(milliseconds: 500));

    // Basic smoke check: find the home title.
    expect(find.text('Citizenship Test Quiz'), findsOneWidget);
  });
}
