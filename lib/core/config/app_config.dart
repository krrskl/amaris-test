import 'package:amaris_test/core/config/app_endpoints.dart';

abstract final class AppConfig {
  /// Inject with: `--dart-define=FUNDS_API_BASE_URL=https://your-endpoint`.
  static const String fundsApiBaseUrl = String.fromEnvironment(
    'FUNDS_API_BASE_URL',
    defaultValue: AppEndpoints.defaultFundsApiBaseUrl,
  );
}
