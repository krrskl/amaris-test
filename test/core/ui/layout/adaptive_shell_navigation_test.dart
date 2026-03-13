import 'package:amaris_test/core/ui/layout/adaptive_app_shell.dart';
import 'package:amaris_test/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpShell(
    WidgetTester tester, {
    required double width,
    required double height,
  }) async {
    LocaleSettings.setLocaleSync(AppLocale.en);

    await tester.pumpWidget(
      ProviderScope(
        child: TranslationProvider(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(size: Size(width, height)),
              child: const AdaptiveAppShell(
                currentLocation: '/home',
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('adapts navigation for compact, medium and expanded widths', (
    tester,
  ) async {
    await pumpShell(tester, width: 390, height: 844);
    expect(find.byKey(const Key('nav-bottom')), findsOneWidget);

    await pumpShell(tester, width: 800, height: 1024);
    expect(find.byKey(const Key('nav-rail')), findsOneWidget);

    await pumpShell(tester, width: 1280, height: 900);
    expect(find.byKey(const Key('nav-sidepanel')), findsOneWidget);
  });
}
