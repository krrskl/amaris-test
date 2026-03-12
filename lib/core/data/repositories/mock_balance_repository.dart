import 'package:amaris_test/core/data/mock/mock_catalog_data.dart';
import 'package:amaris_test/core/domain/models/balance_snapshot.dart';
import 'package:amaris_test/core/domain/repositories/balance_repository.dart';

class MockBalanceRepository implements BalanceRepository {
  @override
  Future<BalanceSnapshot> getBalanceSnapshot() async {
    return MockCatalogData.initialBalance;
  }
}
