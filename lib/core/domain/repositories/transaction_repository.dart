import 'package:amaris_test/core/domain/models/transaction_record.dart';

abstract interface class TransactionRepository {
  Future<List<TransactionRecord>> getTransactions();
}
