import 'package:amaris_test/core/data/persistence/persistence_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'startup_provider.g.dart';

@riverpod
Future<void> startup(Ref ref) async {
  registerErrorHandlers();

  await Hive.initFlutter();
  await Hive.openBox<String>(PersistenceBoxes.portfolioState);
  await Hive.openBox<String>(PersistenceBoxes.settingsState);
}

void registerErrorHandlers() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(title: const Text('An error occurred')),
      body: Center(child: Text(details.toString())),
    );
  };

  if (kReleaseMode) return;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    return true;
  };
}
