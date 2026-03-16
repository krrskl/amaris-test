import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/state/user_preferences_notifier.dart';
import 'package:amaris_test/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_preferences_selectors.g.dart';

@riverpod
UserPreferences currentUserPreferences(Ref ref) {
  return ref.watch(
        userPreferencesNotifierProvider.select((state) => state.valueOrNull),
      ) ??
      UserPreferences.defaults;
}

@riverpod
NotificationMethod userPreferredNotificationMethod(Ref ref) {
  final preferences = ref.watch(currentUserPreferencesProvider);
  return preferences.preferredNotificationMethod;
}

@riverpod
bool requireCancellationConfirmationPreference(Ref ref) {
  final preferences = ref.watch(currentUserPreferencesProvider);
  return preferences.requireCancellationConfirmation;
}

@riverpod
bool isPersistingUserPreferences(Ref ref) {
  return ref.watch(
    userPreferencesNotifierProvider.select((state) => state.isLoading),
  );
}

final userFundsDataSourcePreferenceProvider = Provider<FundsDataSource>((ref) {
  final preferences = ref.watch(currentUserPreferencesProvider);
  return preferences.fundsDataSource;
});

@riverpod
AppLocale preferredAppLocale(Ref ref) {
  final preferences = ref.watch(currentUserPreferencesProvider);
  return switch (preferences.preferredLanguage) {
    PreferredLanguage.en => AppLocale.en,
    PreferredLanguage.esCo => AppLocale.esCo,
  };
}

@riverpod
Locale appLocale(Ref ref) {
  return ref.watch(preferredAppLocaleProvider).flutterLocale;
}
