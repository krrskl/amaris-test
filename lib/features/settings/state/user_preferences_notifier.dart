import 'package:amaris_test/core/data/repositories/hive_user_preferences_repository.dart';
import 'package:amaris_test/core/data/persistence/persistence_constants.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:amaris_test/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>((
  ref,
) {
  final box = Hive.box<String>(PersistenceBoxes.settingsState);
  return HiveUserPreferencesRepository(box: box);
});

final userPreferencesNotifierProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() {
    final repository = ref.watch(userPreferencesRepositoryProvider);
    return repository.loadPreferences();
  }

  Future<void> setPreferredNotificationMethod(NotificationMethod value) async {
    final current = state.valueOrNull ?? await future;
    if (current.preferredNotificationMethod == value) {
      return;
    }

    await _persist(current.copyWith(preferredNotificationMethod: value));
  }

  Future<void> setRequireCancellationConfirmation(bool value) async {
    final current = state.valueOrNull ?? await future;
    if (current.requireCancellationConfirmation == value) {
      return;
    }

    await _persist(current.copyWith(requireCancellationConfirmation: value));
  }

  Future<void> setPreferredLanguage(PreferredLanguage value) async {
    final current = state.valueOrNull ?? await future;
    if (current.preferredLanguage == value) {
      return;
    }

    await _persist(current.copyWith(preferredLanguage: value));
    final locale = switch (value) {
      PreferredLanguage.en => AppLocale.en,
      PreferredLanguage.esCo => AppLocale.esCo,
    };
    await LocaleSettings.setLocale(locale);
  }

  Future<void> resetPreferences() async {
    state = const AsyncLoading<UserPreferences>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userPreferencesRepositoryProvider);
      await repository.resetPreferences();
      return UserPreferences.defaults;
    });
  }

  Future<void> _persist(UserPreferences next) async {
    state = const AsyncLoading<UserPreferences>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userPreferencesRepositoryProvider);
      await repository.savePreferences(next);
      return next;
    });
  }
}
