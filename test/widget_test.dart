// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:citizenship_quiz_app/src/screens/home_screen.dart';
import 'package:citizenship_quiz_app/l10n/app_localizations.dart';

void main() {
  testWidgets('App renders HomeScreen with title', (WidgetTester tester) async {
    // Build a minimal app with localizations and the HomeScreen directly.
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          LocaleNamesLocalizationsDelegate(),
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: const HomeScreen(),
      ),
    );

    // Let frames settle.
    await tester.pumpAndSettle();

    // Expect the German header title.
    expect(find.text('Einbürgerungstest'), findsOneWidget);
  });
}
