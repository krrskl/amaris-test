sealed class UserPreferencesFailure implements Exception {
  const UserPreferencesFailure();

  String get friendlyMessage;

  const factory UserPreferencesFailure.persistence({required String details}) =
      UserPreferencesPersistenceFailure;
}

final class UserPreferencesPersistenceFailure extends UserPreferencesFailure {
  const UserPreferencesPersistenceFailure({required this.details});

  final String details;

  @override
  String get friendlyMessage =>
      'Could not persist user preferences. Please retry.';
}
