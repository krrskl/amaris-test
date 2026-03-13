import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/repositories/fund_repository.dart';
import 'package:amaris_test/core/domain/repositories/portfolio_repository.dart';
import 'package:amaris_test/features/funds/presentation/funds_page.dart';
import 'package:amaris_test/features/funds/state/funds_providers.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fund = Fund(
    id: 'f1',
    name: 'Test Fund',
    minimumAmountCop: 75000,
    category: FundCategory.fpv,
    description: 'Test option',
  );

  testWidgets(
    'subscription dialog shows inline error and then completes successfully',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fundRepositoryProvider.overrideWithValue(
              const _FakeFundRepository(funds: [fund]),
            ),
            portfolioRepositoryProvider.overrideWithValue(
              _FakePortfolioRepository(
                snapshot: PortfolioSnapshot(
                  availableBalanceCop: 500000,
                  holdings: const [],
                  transactions: const [],
                  updatedAt: DateTime(2026, 1, 1).toUtc(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: FundsPage())),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Subscribe'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('subscription-dialog-error')),
        findsOneWidget,
      );
      expect(find.text('Enter a valid amount'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        '100000',
      );
      await tester.tap(
        find.byType(DropdownButtonFormField<NotificationMethod>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('SMS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Subscribe to Test Fund'), findsNothing);
      expect(find.text('Subscription completed'), findsOneWidget);
    },
  );
}

class _FakeFundRepository implements FundRepository {
  const _FakeFundRepository({required this.funds});

  final List<Fund> funds;

  @override
  Future<List<Fund>> getFunds() async => funds;
}

class _FakePortfolioRepository implements PortfolioRepository {
  const _FakePortfolioRepository({required this.snapshot});

  final PortfolioSnapshot snapshot;

  @override
  Future<void> appendTransaction(TransactionRecord record) async {}

  @override
  Future<PortfolioSnapshot> loadPortfolio() async => snapshot;

  @override
  Future<void> savePortfolio(PortfolioSnapshot snapshot) async {}
}
