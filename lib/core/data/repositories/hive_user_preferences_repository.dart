import 'dart:convert';

import 'package:amaris_test/core/data/persistence/persistence_constants.dart';
import 'package:amaris_test/features/settings/domain/errors/user_preferences_failure.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:hive_ce/hive.dart';

class HiveUserPreferencesRepository implements UserPreferencesRepository {
  HiveUserPreferencesRepository({required Box<String> box}) : _box = box;

  final Box<String> _box;

  /// Contract:
  /// - Missing or malformed payload -> return [UserPreferences.defaults].
  /// - Storage read/write failures -> throw
  ///   [UserPreferencesFailure.persistence].
  ///
  /// Preferences are user comfort settings, so decoding issues fallback to
  /// safe defaults while infrastructure failures remain explicit.
  @override
  Future<UserPreferences> loadPreferences() async {
    final String? raw;
    try {
      raw = _box.get(PersistenceKeys.userPreferences);
    } on Object catch (error) {
      throw UserPreferencesFailure.persistence(details: error.toString());
    }

    if (raw == null || raw.isEmpty) {
      return UserPreferences.defaults;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return UserPreferences.defaults;
      }

      return UserPreferences.fromJson(decoded);
    } on Object {
      return UserPreferences.defaults;
    }
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      final raw = jsonEncode(preferences.toJson());
      await _box.put(PersistenceKeys.userPreferences, raw);
    } on Object catch (error) {
      throw UserPreferencesFailure.persistence(details: error.toString());
    }
  }

  @override
  Future<void> resetPreferences() {
    return savePreferences(UserPreferences.defaults);
  }
}
