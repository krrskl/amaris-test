import 'dart:io';

import 'package:amaris_test/core/data/persistence/persistence_constants.dart';
import 'package:amaris_test/core/data/repositories/hive_user_preferences_repository.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  group('HiveUserPreferencesRepository', () {
    late Directory hiveDirectory;
    late Box<String> box;
    late HiveUserPreferencesRepository repository;
    var boxCounter = 0;

    setUp(() async {
      hiveDirectory = await Directory.systemTemp.createTemp(
        'amaris_preferences_repository_',
      );
      Hive.init(hiveDirectory.path);

      box = await Hive.openBox<String>(
        '${PersistenceBoxes.settingsState}_$boxCounter',
      );
      boxCounter += 1;

      repository = HiveUserPreferencesRepository(box: box);
    });

    tearDown(() async {
      if (box.isOpen) {
        await box.deleteFromDisk();
      }
      await Hive.close();

      if (await hiveDirectory.exists()) {
        await hiveDirectory.delete(recursive: true);
      }
    });

    test('returns defaults when preferences are missing', () async {
      final loaded = await repository.loadPreferences();

      expect(loaded, UserPreferences.defaults);
    });

    test('saves and loads preferences successfully', () async {
      const preferences = UserPreferences(
        preferredNotificationMethod: NotificationMethod.email,
        requireCancellationConfirmation: false,
      );

      await repository.savePreferences(preferences);
      final loaded = await repository.loadPreferences();

      expect(loaded, preferences);
    });

    test('returns defaults when persisted payload is malformed json', () async {
      await box.put(PersistenceKeys.userPreferences, '{invalid-json');

      final loaded = await repository.loadPreferences();

      expect(loaded, UserPreferences.defaults);
    });
  });
}
