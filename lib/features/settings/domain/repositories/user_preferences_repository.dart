import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';

abstract interface class UserPreferencesRepository {
  Future<UserPreferences> loadPreferences();

  Future<void> savePreferences(UserPreferences preferences);

  Future<void> resetPreferences();
}
