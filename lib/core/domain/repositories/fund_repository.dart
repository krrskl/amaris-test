import 'package:amaris_test/core/domain/models/fund.dart';

abstract interface class FundRepository {
  Future<List<Fund>> getFunds();
}
