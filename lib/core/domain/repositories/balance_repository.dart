import 'package:amaris_test/core/domain/models/balance_snapshot.dart';

abstract interface class BalanceRepository {
  Future<BalanceSnapshot> getBalanceSnapshot();
}
