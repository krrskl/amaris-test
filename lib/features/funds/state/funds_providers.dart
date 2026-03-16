import 'package:amaris_test/core/config/app_config.dart';
import 'package:amaris_test/core/data/repositories/mock_fund_repository.dart';
import 'package:amaris_test/core/data/repositories/remote_fund_repository.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/repositories/fund_repository.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/state/user_preferences_selectors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'funds_providers.g.dart';

enum FundTypeFilter { all, fpv, fic }

final fundsApiDioProvider = Provider<Dio>((ref) {
  final baseUrl = AppConfig.fundsApiBaseUrl;

  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );
});

@riverpod
FundRepository fundRepository(Ref ref) {
  final source = ref.watch(userFundsDataSourcePreferenceProvider);
  return switch (source) {
    FundsDataSource.localMock => MockFundRepository(),
    FundsDataSource.api => RemoteFundRepository(
      dio: ref.watch(fundsApiDioProvider),
    ),
  };
}

@riverpod
Future<List<Fund>> funds(Ref ref) {
  final repo = ref.watch(fundRepositoryProvider);
  return repo.getFunds();
}

final selectedFundTypeFilterProvider =
    StateProvider.autoDispose<FundTypeFilter>((ref) => FundTypeFilter.all);

final fundSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredFundsProvider = Provider.autoDispose<AsyncValue<List<Fund>>>((
  ref,
) {
  final funds = ref.watch(fundsProvider);
  final selectedType = ref.watch(selectedFundTypeFilterProvider);
  final query = ref.watch(fundSearchQueryProvider).trim().toLowerCase();

  return funds.whenData((items) {
    return items
        .where((fund) {
          final matchesType = switch (selectedType) {
            FundTypeFilter.all => true,
            FundTypeFilter.fpv => fund.category == FundCategory.fpv,
            FundTypeFilter.fic => fund.category == FundCategory.fic,
          };

          if (!matchesType) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          return fund.name.toLowerCase().contains(query);
        })
        .toList(growable: false);
  });
});

@riverpod
bool hasActiveFundFilters(Ref ref) {
  final selectedType = ref.watch(selectedFundTypeFilterProvider);
  final query = ref.watch(fundSearchQueryProvider);
  return selectedType != FundTypeFilter.all || query.trim().isNotEmpty;
}

@riverpod
int? availableBalanceForFunds(Ref ref) {
  return ref.watch(
    portfolioAsyncNotifierProvider.select(
      (state) => state.valueOrNull?.availableBalanceCop,
    ),
  );
}

@riverpod
NotificationMethod preferredNotificationMethodForFunds(Ref ref) {
  return ref.watch(userPreferredNotificationMethodProvider);
}
