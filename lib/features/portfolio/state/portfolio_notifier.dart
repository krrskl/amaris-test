import 'package:amaris_test/core/data/repositories/hive_portfolio_repository.dart';
import 'package:amaris_test/core/data/persistence/persistence_constants.dart';
import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/fund_holding.dart';
import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/repositories/portfolio_repository.dart';
import 'package:amaris_test/core/domain/services/portfolio_rules.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'portfolio_notifier.g.dart';

@Riverpod(keepAlive: true)
PortfolioRepository portfolioRepository(Ref ref) {
  final box = Hive.box<String>(PersistenceBoxes.portfolioState);
  return HivePortfolioRepository(box: box);
}

@riverpod
PortfolioRules portfolioRules(Ref ref) => const PortfolioRules();

@Riverpod(keepAlive: true)
class PortfolioAsyncNotifier extends _$PortfolioAsyncNotifier {
  @override
  Future<PortfolioSnapshot> build() async {
    final repository = ref.watch(portfolioRepositoryProvider);
    return repository.loadPortfolio();
  }

  Future<void> subscribe({
    required Fund fund,
    required int amountCop,
    required NotificationMethod notificationMethod,
  }) async {
    final current = state.valueOrNull ?? await future;
    final rules = ref.read(portfolioRulesProvider);

    state = const AsyncLoading<PortfolioSnapshot>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      rules.validateSubscription(
        fund: fund,
        amountCop: amountCop,
        availableBalanceCop: current.availableBalanceCop,
        notificationMethod: notificationMethod,
      );

      final now = DateTime.now().toUtc();
      final transaction = TransactionRecord(
        id: 'txn_${now.microsecondsSinceEpoch}',
        timestamp: now,
        fundName: fund.name,
        amountCop: amountCop,
        type: TransactionType.subscription,
        notificationMethod: notificationMethod,
      );

      final holding = FundHolding(
        id: 'holding_${now.microsecondsSinceEpoch}',
        fundId: fund.id,
        fundName: fund.name,
        subscribedAmountCop: amountCop,
        notificationMethod: notificationMethod,
        subscribedAt: now,
      );

      final repository = ref.read(portfolioRepositoryProvider);
      await repository.appendTransaction(transaction);

      final next = current.copyWith(
        availableBalanceCop: rules.calculateBalanceAfterSubscription(
          currentBalanceCop: current.availableBalanceCop,
          amountCop: amountCop,
        ),
        holdings: <FundHolding>[...current.holdings, holding],
        transactions: <TransactionRecord>[...current.transactions, transaction],
        updatedAt: now,
      );

      await repository.savePortfolio(next);
      return next;
    });
  }

  Future<void> cancelHolding({required String holdingId}) async {
    final current = state.valueOrNull ?? await future;
    final rules = ref.read(portfolioRulesProvider);

    state = const AsyncLoading<PortfolioSnapshot>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final holding = current.holdings
          .where((item) => item.id == holdingId)
          .firstOrNull;
      if (holding == null) {
        throw PortfolioFailure.holdingNotFound(holdingId: holdingId);
      }

      final now = DateTime.now().toUtc();
      final transaction = TransactionRecord(
        id: 'txn_${now.microsecondsSinceEpoch}',
        timestamp: now,
        fundName: holding.fundName,
        amountCop: holding.subscribedAmountCop,
        type: TransactionType.cancellation,
        notificationMethod: NotificationMethod.none,
      );

      final repository = ref.read(portfolioRepositoryProvider);
      await repository.appendTransaction(transaction);

      final next = current.copyWith(
        availableBalanceCop: rules.calculateBalanceAfterCancellation(
          currentBalanceCop: current.availableBalanceCop,
          originalSubscribedAmountCop: holding.subscribedAmountCop,
        ),
        holdings: current.holdings
            .where((item) => item.id != holding.id)
            .toList(growable: false),
        transactions: <TransactionRecord>[...current.transactions, transaction],
        updatedAt: now,
      );

      await repository.savePortfolio(next);
      return next;
    });
  }

  Future<void> resetPortfolioData() async {
    state = const AsyncLoading<PortfolioSnapshot>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final initial = PortfolioSnapshot.initial();
      final repository = ref.read(portfolioRepositoryProvider);
      await repository.savePortfolio(initial);
      return initial;
    });
  }
}
