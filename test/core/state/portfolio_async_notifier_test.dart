import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/fund_holding.dart';
import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/repositories/portfolio_repository.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_queries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fund = Fund(
    id: 'fund-1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmountCop: 75000,
    category: FundCategory.fpv,
    description: 'Voluntary Pension Fund',
  );

  group('PortfolioAsyncNotifier', () {
    test('subscribe updates holdings, ledger and available balance', () async {
      final repository = _InMemoryPortfolioRepository(
        snapshot: PortfolioSnapshot.initial(),
      );

      final container = ProviderContainer(
        overrides: [portfolioRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(portfolioAsyncNotifierProvider.future);

      await container
          .read(portfolioAsyncNotifierProvider.notifier)
          .subscribe(
            fund: fund,
            amountCop: 100000,
            notificationMethod: NotificationMethod.email,
          );

      final state = container.read(portfolioAsyncNotifierProvider);
      final snapshot = state.requireValue;

      expect(state.hasError, isFalse);
      expect(snapshot.availableBalanceCop, 400000);
      expect(snapshot.holdings, hasLength(1));
      expect(snapshot.transactions, hasLength(1));
      expect(snapshot.transactions.first.type, TransactionType.subscription);
    });

    test('subscribe fails when amount is below minimum', () async {
      final repository = _InMemoryPortfolioRepository(
        snapshot: PortfolioSnapshot.initial(),
      );

      final container = ProviderContainer(
        overrides: [portfolioRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(portfolioAsyncNotifierProvider.future);
      await container
          .read(portfolioAsyncNotifierProvider.notifier)
          .subscribe(
            fund: fund,
            amountCop: 50000,
            notificationMethod: NotificationMethod.sms,
          );

      final state = container.read(portfolioAsyncNotifierProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<MinimumAmountFailure>());
    });

    test('cancelHolding credits original subscribed amount back', () async {
      final subscribedAt = DateTime.parse('2026-03-11T12:00:00Z');
      final repository = _InMemoryPortfolioRepository(
        snapshot: PortfolioSnapshot(
          availableBalanceCop: 400000,
          holdings: [
            FundHolding(
              id: 'holding-1',
              fundId: fund.id,
              fundName: fund.name,
              subscribedAmountCop: 100000,
              notificationMethod: NotificationMethod.email,
              subscribedAt: subscribedAt,
            ),
          ],
          transactions: const [],
          updatedAt: subscribedAt,
        ),
      );

      final container = ProviderContainer(
        overrides: [portfolioRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(portfolioAsyncNotifierProvider.future);
      await container
          .read(portfolioAsyncNotifierProvider.notifier)
          .cancelHolding(holdingId: 'holding-1');

      final state = container.read(portfolioAsyncNotifierProvider);
      final snapshot = state.requireValue;

      expect(state.hasError, isFalse);
      expect(snapshot.availableBalanceCop, 500000);
      expect(snapshot.holdings, isEmpty);
      expect(snapshot.transactions, hasLength(1));
      expect(snapshot.transactions.first.type, TransactionType.cancellation);
      expect(snapshot.transactions.first.amountCop, 100000);
    });

    test(
      'portfolioSnapshotForQueries returns previous snapshot after mutation error',
      () async {
        final repository = _InMemoryPortfolioRepository(
          snapshot: PortfolioSnapshot.initial(),
        );
        final container = ProviderContainer(
          overrides: [
            portfolioRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        final snapshotSubscription = container
            .listen<AsyncValue<PortfolioSnapshot>>(
              portfolioSnapshotForQueriesProvider,
              (_, _) {},
              fireImmediately: true,
            );
        addTearDown(snapshotSubscription.close);

        final baseline = await container.read(
          portfolioSnapshotForQueriesProvider.future,
        );
        expect(baseline.availableBalanceCop, 500000);

        await container
            .read(portfolioAsyncNotifierProvider.notifier)
            .subscribe(
              fund: fund,
              amountCop: 900000,
              notificationMethod: NotificationMethod.email,
            );

        final snapshotAfterFailure = await container.read(
          portfolioSnapshotForQueriesProvider.future,
        );
        expect(
          snapshotAfterFailure.availableBalanceCop,
          baseline.availableBalanceCop,
        );
        expect(snapshotAfterFailure.transactions, baseline.transactions);
      },
    );

    test(
      'portfolioSnapshotForQueries falls back to repository when notifier future fails',
      () async {
        final fallbackSnapshot = PortfolioSnapshot(
          availableBalanceCop: 275000,
          holdings: const [],
          transactions: const [],
          updatedAt: DateTime.parse('2026-03-11T12:00:00Z'),
        );
        final repository = _FailThenRecoverPortfolioRepository(
          recovered: fallbackSnapshot,
        );
        final container = ProviderContainer(
          overrides: [
            portfolioRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        final snapshotSubscription = container
            .listen<AsyncValue<PortfolioSnapshot>>(
              portfolioSnapshotForQueriesProvider,
              (_, _) {},
              fireImmediately: true,
            );
        addTearDown(snapshotSubscription.close);

        await expectLater(
          container.read(portfolioAsyncNotifierProvider.future),
          throwsA(isA<StateError>()),
        );

        final queried = await container.read(
          portfolioSnapshotForQueriesProvider.future,
        );
        expect(queried, fallbackSnapshot);
      },
    );
  });
}

class _InMemoryPortfolioRepository implements PortfolioRepository {
  _InMemoryPortfolioRepository({required PortfolioSnapshot snapshot})
    : _snapshot = snapshot;

  PortfolioSnapshot _snapshot;

  @override
  Future<void> appendTransaction(TransactionRecord record) async {
    _snapshot = _snapshot.copyWith(
      transactions: <TransactionRecord>[..._snapshot.transactions, record],
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<PortfolioSnapshot> loadPortfolio() async => _snapshot;

  @override
  Future<void> savePortfolio(PortfolioSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}

class _FailThenRecoverPortfolioRepository implements PortfolioRepository {
  _FailThenRecoverPortfolioRepository({required PortfolioSnapshot recovered})
    : _snapshot = recovered;

  PortfolioSnapshot _snapshot;
  var _loadAttempts = 0;

  @override
  Future<void> appendTransaction(TransactionRecord record) async {
    _snapshot = _snapshot.copyWith(
      transactions: <TransactionRecord>[..._snapshot.transactions, record],
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<PortfolioSnapshot> loadPortfolio() async {
    _loadAttempts += 1;
    if (_loadAttempts == 1) {
      throw StateError('bootstrap failure');
    }

    return _snapshot;
  }

  @override
  Future<void> savePortfolio(PortfolioSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}
