import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:amaris_test/features/settings/state/user_preferences_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserPreferencesNotifier', () {
    test('loads and persists updated preferences', () async {
      final repository = _InMemoryUserPreferencesRepository(
        initial: const UserPreferences(
          preferredNotificationMethod: NotificationMethod.email,
          requireCancellationConfirmation: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          userPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(
        userPreferencesNotifierProvider.future,
      );
      expect(initial.preferredNotificationMethod, NotificationMethod.email);
      expect(initial.requireCancellationConfirmation, isTrue);

      await container
          .read(userPreferencesNotifierProvider.notifier)
          .setPreferredNotificationMethod(NotificationMethod.sms);
      await container
          .read(userPreferencesNotifierProvider.notifier)
          .setRequireCancellationConfirmation(false);

      final state = container
          .read(userPreferencesNotifierProvider)
          .requireValue;
      expect(state.preferredNotificationMethod, NotificationMethod.sms);
      expect(state.requireCancellationConfirmation, isFalse);

      expect(repository.saved, isNotNull);
      expect(
        repository.saved!.preferredNotificationMethod,
        NotificationMethod.sms,
      );
      expect(repository.saved!.requireCancellationConfirmation, isFalse);
    });

    test('resetPreferences restores defaults', () async {
      final repository = _InMemoryUserPreferencesRepository(
        initial: const UserPreferences(
          preferredNotificationMethod: NotificationMethod.sms,
          requireCancellationConfirmation: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          userPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userPreferencesNotifierProvider.future);
      await container
          .read(userPreferencesNotifierProvider.notifier)
          .resetPreferences();

      final state = container
          .read(userPreferencesNotifierProvider)
          .requireValue;
      expect(state, UserPreferences.defaults);
      expect(repository.saved, UserPreferences.defaults);
    });
  });
}

class _InMemoryUserPreferencesRepository implements UserPreferencesRepository {
  _InMemoryUserPreferencesRepository({required UserPreferences initial})
    : _current = initial;

  UserPreferences _current;
  UserPreferences? saved;

  @override
  Future<UserPreferences> loadPreferences() async => _current;

  @override
  Future<void> resetPreferences() async {
    _current = UserPreferences.defaults;
    saved = _current;
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _current = preferences;
    saved = preferences;
  }
}
