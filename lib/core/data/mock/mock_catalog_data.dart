import 'package:amaris_test/core/domain/models/balance_snapshot.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';

abstract final class MockCatalogData {
  static final funds = <Fund>[
    const Fund(
      id: '1',
      name: 'FPV_BTG_PACTUAL_RECAUDADORA',
      minimumAmountCop: 75000,
      category: FundCategory.fpv,
      description: 'Voluntary Pension Fund',
    ),
    const Fund(
      id: '2',
      name: 'FPV_BTG_PACTUAL_ECOPETROL',
      minimumAmountCop: 125000,
      category: FundCategory.fpv,
      description: 'Voluntary Pension Fund',
    ),
    const Fund(
      id: '3',
      name: 'DEUDAPRIVADA',
      minimumAmountCop: 50000,
      category: FundCategory.fic,
      description: 'Collective Investment Fund',
    ),
    const Fund(
      id: '4',
      name: 'FDO-ACCIONES',
      minimumAmountCop: 250000,
      category: FundCategory.fic,
      description: 'Collective Investment Fund',
    ),
    const Fund(
      id: '5',
      name: 'FPV_BTG_PACTUAL_DINAMICA',
      minimumAmountCop: 100000,
      category: FundCategory.fpv,
      description: 'Voluntary Pension Fund',
    ),
  ];

  static final transactions = <TransactionRecord>[
    TransactionRecord(
      id: 'txn_001',
      timestamp: DateTime.parse('2026-03-10T10:00:00Z'),
      fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
      amountCop: 100000,
      type: TransactionType.subscription,
      notificationMethod: NotificationMethod.email,
    ),
    TransactionRecord(
      id: 'txn_002',
      timestamp: DateTime.parse('2026-03-10T12:00:00Z'),
      fundName: 'DEUDAPRIVADA',
      amountCop: 50000,
      type: TransactionType.subscription,
      notificationMethod: NotificationMethod.sms,
    ),
  ];

  static final initialBalance = BalanceSnapshot(
    amountCop: 500000,
    updatedAt: DateTime.parse('2026-03-10T12:00:00Z'),
  );
}
