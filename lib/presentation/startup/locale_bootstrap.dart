import 'package:amaris_test/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeBootstrapProvider = FutureProvider.family<void, AppLocale>((
  ref,
  preferredLocale,
) async {
  await ensurePreferredLocaleLoaded(preferredLocale);
});

Future<void> ensurePreferredLocaleLoaded(AppLocale preferredLocale) async {
  if (LocaleSettings.currentLocale == preferredLocale) {
    return;
  }

  await LocaleSettings.setLocale(preferredLocale);
}
