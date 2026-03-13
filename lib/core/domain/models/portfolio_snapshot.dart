import 'package:amaris_test/core/domain/models/fund_holding.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_snapshot.freezed.dart';
part 'portfolio_snapshot.g.dart';

@freezed
abstract class PortfolioSnapshot with _$PortfolioSnapshot {
  const factory PortfolioSnapshot({
    required int availableBalanceCop,
    required List<FundHolding> holdings,
    required List<TransactionRecord> transactions,
    required DateTime updatedAt,
  }) = _PortfolioSnapshot;

  factory PortfolioSnapshot.initial() => PortfolioSnapshot(
    availableBalanceCop: 500000,
    holdings: const <FundHolding>[],
    transactions: const <TransactionRecord>[],
    updatedAt: DateTime.now().toUtc(),
  );

  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSnapshotFromJson(json);
}
