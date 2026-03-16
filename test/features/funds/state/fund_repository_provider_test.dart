import 'package:amaris_test/core/data/repositories/mock_fund_repository.dart';
import 'package:amaris_test/core/data/repositories/remote_fund_repository.dart';
import 'package:amaris_test/features/funds/state/funds_providers.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/state/user_preferences_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fundRepositoryProvider', () {
    test('returns mock repository when source preference is local', () {
      final container = ProviderContainer(
        overrides: [
          userFundsDataSourcePreferenceProvider.overrideWithValue(
            FundsDataSource.localMock,
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(fundRepositoryProvider);

      expect(repository, isA<MockFundRepository>());
    });

    test('returns remote repository when source preference is api', () {
      final container = ProviderContainer(
        overrides: [
          userFundsDataSourcePreferenceProvider.overrideWithValue(
            FundsDataSource.api,
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(fundRepositoryProvider);

      expect(repository, isA<RemoteFundRepository>());
    });
  });
}
