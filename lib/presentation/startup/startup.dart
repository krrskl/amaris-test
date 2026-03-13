import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'startup_error.dart';
import 'startup_loading.dart';
import 'startup_provider.dart';

class StartupWidget extends ConsumerWidget {
  const StartupWidget({super.key, required this.onLoaded});

  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(startupProvider);

    return appStartupState.when(
      data: (_) => onLoaded(context),
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        home: StartupLoadingWidget(),
      ),
      error: (e, st) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        home: StartupErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(startupProvider),
        ),
      ),
    );
  }
}
