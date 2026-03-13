import 'package:amaris_test/core/domain/models/transaction_record.dart';

class UserPreferences {
  const UserPreferences({
    this.preferredNotificationMethod = defaultNotificationMethod,
    this.requireCancellationConfirmation =
        defaultRequireCancellationConfirmation,
    this.preferredLanguage = defaultPreferredLanguage,
  });

  static const NotificationMethod defaultNotificationMethod =
      NotificationMethod.none;
  static const bool defaultRequireCancellationConfirmation = true;
  static const PreferredLanguage defaultPreferredLanguage =
      PreferredLanguage.en;

  static const defaults = UserPreferences();

  final NotificationMethod preferredNotificationMethod;
  final bool requireCancellationConfirmation;
  final PreferredLanguage preferredLanguage;

  UserPreferences copyWith({
    NotificationMethod? preferredNotificationMethod,
    bool? requireCancellationConfirmation,
    PreferredLanguage? preferredLanguage,
  }) {
    return UserPreferences(
      preferredNotificationMethod:
          preferredNotificationMethod ?? this.preferredNotificationMethod,
      requireCancellationConfirmation:
          requireCancellationConfirmation ??
          this.requireCancellationConfirmation,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'preferredNotificationMethod': preferredNotificationMethod.name,
      'requireCancellationConfirmation': requireCancellationConfirmation,
      'preferredLanguage': preferredLanguage.code,
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
      preferredLanguage: PreferredLanguage.fromCode(json['preferredLanguage']),
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
            requireCancellationConfirmation &&
        other.preferredLanguage == preferredLanguage;
  }

  @override
  int get hashCode => Object.hash(
    preferredNotificationMethod,
    requireCancellationConfirmation,
    preferredLanguage,
  );
}

enum PreferredLanguage {
  en('en'),
  esCo('es_CO');

  const PreferredLanguage(this.code);

  final String code;

  static PreferredLanguage fromCode(dynamic value) {
    if (value is String) {
      return PreferredLanguage.values.firstWhere(
        (item) => item.code == value,
        orElse: () => UserPreferences.defaultPreferredLanguage,
      );
    }

    return UserPreferences.defaultPreferredLanguage;
  }
}
