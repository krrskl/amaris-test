import 'dart:convert';
import 'dart:io';

import 'package:amaris_test/core/data/persistence/persistence_constants.dart';
import 'package:amaris_test/core/data/repositories/hive_portfolio_repository.dart';
import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/fund_holding.dart';
import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  group('HivePortfolioRepository', () {
    late Directory hiveDirectory;
    late Box<String> box;
    late HivePortfolioRepository repository;
    var boxCounter = 0;

    setUp(() async {
      hiveDirectory = await Directory.systemTemp.createTemp(
        'amaris_portfolio_repository_',
      );
      Hive.init(hiveDirectory.path);

      box = await Hive.openBox<String>(
        '${PersistenceBoxes.portfolioState}_$boxCounter',
      );
      boxCounter += 1;

      repository = HivePortfolioRepository(box: box);
    });

    tearDown(() async {
      if (box.isOpen) {
        await box.deleteFromDisk();
      }
      await Hive.close();

      if (await hiveDirectory.exists()) {
        await hiveDirectory.delete(recursive: true);
      }
    });

    test(
      'seeds and returns initial portfolio when payload is missing',
      () async {
        final loaded = await repository.loadPortfolio();
        final storedRaw = box.get(PersistenceKeys.portfolioSnapshot);

        expect(loaded.availableBalanceCop, 500000);
        expect(loaded.holdings, isEmpty);
        expect(loaded.transactions, isEmpty);
        expect(storedRaw, isNotNull);

        final persisted = PortfolioSnapshot.fromJson(
          jsonDecode(storedRaw!) as Map<String, dynamic>,
        );
        expect(persisted, loaded);
      },
    );

    test('saves and loads portfolio snapshot successfully', () async {
      final snapshot = PortfolioSnapshot(
        availableBalanceCop: 333000,
        holdings: <FundHolding>[
          FundHolding(
            id: 'holding-1',
            fundId: 'fund-1',
            fundName: 'FPV_TEST_FUND',
            subscribedAmountCop: 120000,
            notificationMethod: NotificationMethod.sms,
            subscribedAt: DateTime.parse('2026-03-11T10:00:00Z'),
          ),
        ],
        transactions: <TransactionRecord>[
          TransactionRecord(
            id: 'tx-1',
            timestamp: DateTime.parse('2026-03-11T10:01:00Z'),
            fundName: 'FPV_TEST_FUND',
            amountCop: 120000,
            type: TransactionType.subscription,
            notificationMethod: NotificationMethod.sms,
          ),
        ],
        updatedAt: DateTime.parse('2026-03-11T10:05:00Z'),
      );

      await repository.savePortfolio(snapshot);
      final loaded = await repository.loadPortfolio();

      expect(loaded, snapshot);
    });

    test(
      'maps malformed json payload to typed persistence failure on load',
      () async {
        await box.put(PersistenceKeys.portfolioSnapshot, '{invalid-json');

        await expectLater(
          repository.loadPortfolio(),
          throwsA(isA<PersistenceFailure>()),
        );
      },
    );
  });
}
