import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/state/user_preferences_notifier.dart';
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
