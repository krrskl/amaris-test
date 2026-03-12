import 'package:amaris_test/core/data/mock/mock_catalog_data.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  @override
  Future<List<TransactionRecord>> getTransactions() async {
    return MockCatalogData.transactions;
  }
}
