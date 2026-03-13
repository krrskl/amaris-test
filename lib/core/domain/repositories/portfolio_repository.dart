import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';

abstract interface class PortfolioRepository {
  Future<PortfolioSnapshot> loadPortfolio();

  Future<void> savePortfolio(PortfolioSnapshot snapshot);

  Future<void> appendTransaction(TransactionRecord record);
}
