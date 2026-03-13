import 'package:amaris_test/app/routing/app_router_provider.dart';
import 'package:amaris_test/core/ui/theme/app_theme.dart';
import 'package:amaris_test/features/settings/state/user_preferences_selectors.dart';
import 'package:amaris_test/i18n/strings.g.dart';
import 'package:amaris_test/presentation/startup/locale_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class StartupApp extends ConsumerWidget {
  const StartupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);
    final preferredLocale = ref.watch(preferredAppLocaleProvider);

    ref.watch(localeBootstrapProvider(preferredLocale));

    return TranslationProvider(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => context.t.app.title,
        theme: AppTheme.lightTheme,
        locale: locale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router,
      ),
    );
  }
}
