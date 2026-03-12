import 'package:amaris_test/app/routing/app_router_provider.dart';
import 'package:amaris_test/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmarisApp extends ConsumerWidget {
  const AmarisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BTG Fund Management',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
