/// Centralized persistence names used by Hive.
///
/// Migration notes:
/// - Keep existing box/key string values stable to preserve persisted data.
/// - When introducing a new schema, add a versioned key instead of renaming.
/// - If a rename is unavoidable, implement explicit read-migrate-write logic.
abstract final class PersistenceBoxes {
  static const String portfolioState = 'portfolio_state';
  static const String settingsState = 'settings_state';
}

abstract final class PersistenceKeys {
  static const String portfolioSnapshot = 'portfolio_snapshot';
  static const String userPreferences = 'user_preferences';
}
