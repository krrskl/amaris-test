import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/services/portfolio_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rules = PortfolioRules();
  const fund = Fund(
    id: 'fund-1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmountCop: 75000,
    category: FundCategory.fpv,
    description: 'Voluntary Pension Fund',
  );

  group('PortfolioRules.validateSubscription', () {
    test('throws when amount is below fund minimum', () {
      expect(
        () => rules.validateSubscription(
          fund: fund,
          amountCop: 50000,
          availableBalanceCop: 500000,
          notificationMethod: NotificationMethod.email,
        ),
        throwsA(isA<MinimumAmountFailure>()),
      );
    });

    test('throws when available balance is insufficient', () {
      expect(
        () => rules.validateSubscription(
          fund: fund,
          amountCop: 100000,
          availableBalanceCop: 90000,
          notificationMethod: NotificationMethod.email,
        ),
        throwsA(isA<InsufficientBalanceFailure>()),
      );
    });

    test('throws when notification method is not selected', () {
      expect(
        () => rules.validateSubscription(
          fund: fund,
          amountCop: 100000,
          availableBalanceCop: 500000,
          notificationMethod: NotificationMethod.none,
        ),
        throwsA(isA<NotificationRequiredFailure>()),
      );
    });

    test('passes when all business rules are satisfied', () {
      expect(
        () => rules.validateSubscription(
          fund: fund,
          amountCop: 100000,
          availableBalanceCop: 500000,
          notificationMethod: NotificationMethod.sms,
        ),
        returnsNormally,
      );
    });
  });

  group('PortfolioRules balance math', () {
    test('deducts subscription amount from current balance', () {
      final next = rules.calculateBalanceAfterSubscription(
        currentBalanceCop: 500000,
        amountCop: 125000,
      );

      expect(next, 375000);
    });

    test('credits original subscribed amount on cancellation', () {
      final next = rules.calculateBalanceAfterCancellation(
        currentBalanceCop: 325000,
        originalSubscribedAmountCop: 125000,
      );

      expect(next, 450000);
    });
  });
}
