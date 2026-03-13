import 'package:amaris_test/core/domain/models/balance_snapshot.dart';
import 'package:amaris_test/core/domain/models/fund_holding.dart';
import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'portfolio_queries.g.dart';

@riverpod
Future<List<TransactionRecord>> transactions(Ref ref) async {
  final snapshot = await ref.watch(portfolioSnapshotForQueriesProvider.future);
  return snapshot.transactions.reversed.toList(growable: false);
}

@riverpod
Future<PortfolioSnapshot> portfolioSnapshotForQueries(Ref ref) async {
  final portfolioState = ref.watch(portfolioAsyncNotifierProvider);
  final knownSnapshot = portfolioState.valueOrNull;

  if (knownSnapshot != null) {
    return knownSnapshot;
  }

  if (portfolioState.hasError) {
    final repository = ref.watch(portfolioRepositoryProvider);
    return repository.loadPortfolio();
  }

  try {
    return await ref.watch(portfolioAsyncNotifierProvider.future);
  } on Object {
    final latestSnapshot = ref.read(portfolioAsyncNotifierProvider).valueOrNull;
    if (latestSnapshot != null) {
      return latestSnapshot;
    }

    final repository = ref.watch(portfolioRepositoryProvider);
    return repository.loadPortfolio();
  }
}

@riverpod
Future<BalanceSnapshot> balanceSnapshot(Ref ref) async {
  final snapshot = await ref.watch(portfolioSnapshotForQueriesProvider.future);
  return BalanceSnapshot(
    amountCop: snapshot.availableBalanceCop,
    updatedAt: snapshot.updatedAt,
  );
}

@riverpod
Future<List<FundHolding>> activeHoldings(Ref ref) async {
  final snapshot = await ref.watch(portfolioSnapshotForQueriesProvider.future);
  return snapshot.holdings.reversed.toList(growable: false);
}
