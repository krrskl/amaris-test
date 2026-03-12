import 'package:amaris_test/core/data/repositories/mock_balance_repository.dart';
import 'package:amaris_test/core/data/repositories/mock_fund_repository.dart';
import 'package:amaris_test/core/data/repositories/mock_transaction_repository.dart';
import 'package:amaris_test/core/domain/models/balance_snapshot.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/repositories/balance_repository.dart';
import 'package:amaris_test/core/domain/repositories/fund_repository.dart';
import 'package:amaris_test/core/domain/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
FundRepository fundRepository(Ref ref) => MockFundRepository();

@riverpod
TransactionRepository transactionRepository(Ref ref) =>
    MockTransactionRepository();

@riverpod
BalanceRepository balanceRepository(Ref ref) => MockBalanceRepository();

@riverpod
Future<List<Fund>> funds(Ref ref) {
  final repo = ref.watch(fundRepositoryProvider);
  return repo.getFunds();
}

@riverpod
Future<List<TransactionRecord>> transactions(Ref ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactions();
}

@riverpod
Future<BalanceSnapshot> balanceSnapshot(Ref ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  return repo.getBalanceSnapshot();
}
