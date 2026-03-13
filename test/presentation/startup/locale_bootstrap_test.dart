import 'package:amaris_test/i18n/strings.g.dart';
import 'package:amaris_test/presentation/startup/locale_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ensurePreferredLocaleLoaded', () {
    setUp(() async {
      await LocaleSettings.setLocale(AppLocale.en);
    });

    test('loads deferred spanish locale without throwing', () async {
      await expectLater(ensurePreferredLocaleLoaded(AppLocale.esCo), completes);

      expect(LocaleSettings.currentLocale, AppLocale.esCo);
    });

    test('keeps english locale as default', () async {
      await ensurePreferredLocaleLoaded(AppLocale.en);

      expect(LocaleSettings.currentLocale, AppLocale.en);
    });
  });
}
