import 'package:amaris_test/core/domain/models/transaction_record.dart';

class UserPreferences {
  const UserPreferences({
    this.preferredNotificationMethod = defaultNotificationMethod,
    this.requireCancellationConfirmation =
        defaultRequireCancellationConfirmation,
  });

  static const NotificationMethod defaultNotificationMethod =
      NotificationMethod.none;
  static const bool defaultRequireCancellationConfirmation = true;

  static const defaults = UserPreferences();

  final NotificationMethod preferredNotificationMethod;
  final bool requireCancellationConfirmation;

  UserPreferences copyWith({
    NotificationMethod? preferredNotificationMethod,
    bool? requireCancellationConfirmation,
    bool? showSuccessSnackbars,
  }) {
    return UserPreferences(
      preferredNotificationMethod:
          preferredNotificationMethod ?? this.preferredNotificationMethod,
      requireCancellationConfirmation:
          requireCancellationConfirmation ??
          this.requireCancellationConfirmation,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'preferredNotificationMethod': preferredNotificationMethod.name,
      'requireCancellationConfirmation': requireCancellationConfirmation,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredNotificationMethod: _parseNotificationMethod(
        json['preferredNotificationMethod'],
      ),
      requireCancellationConfirmation: _parseBool(
        json['requireCancellationConfirmation'],
        defaultRequireCancellationConfirmation,
      ),
    );
  }

  static NotificationMethod _parseNotificationMethod(dynamic value) {
    if (value is String) {
      return NotificationMethod.values.firstWhere(
        (item) => item.name == value,
        orElse: () => defaultNotificationMethod,
      );
    }

    return defaultNotificationMethod;
  }

  static bool _parseBool(dynamic value, bool fallback) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      if (value.toLowerCase() == 'true') {
        return true;
      }
      if (value.toLowerCase() == 'false') {
        return false;
      }
    }

    return fallback;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UserPreferences &&
        other.preferredNotificationMethod == preferredNotificationMethod &&
        other.requireCancellationConfirmation ==
            requireCancellationConfirmation;
  }

  @override
  int get hashCode =>
      Object.hash(preferredNotificationMethod, requireCancellationConfirmation);
}
