import 'package:amaris_test/core/data/mock/mock_catalog_data.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/repositories/fund_repository.dart';

class MockFundRepository implements FundRepository {
  @override
  Future<List<Fund>> getFunds() async {
    return MockCatalogData.funds;
  }
}
