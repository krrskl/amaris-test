import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';

class PortfolioRules {
  const PortfolioRules();

  void validateSubscription({
    required Fund fund,
    required int amountCop,
    required int availableBalanceCop,
    required NotificationMethod notificationMethod,
  }) {
    if (notificationMethod == NotificationMethod.none) {
      throw const PortfolioFailure.notificationRequired();
    }

    if (amountCop < fund.minimumAmountCop) {
      throw PortfolioFailure.minimumAmount(
        minimumAmountCop: fund.minimumAmountCop,
        attemptedAmountCop: amountCop,
      );
    }

    if (availableBalanceCop < amountCop) {
      throw PortfolioFailure.insufficientBalance(
        balanceCop: availableBalanceCop,
        attemptedAmountCop: amountCop,
      );
    }
  }

  int calculateBalanceAfterSubscription({
    required int currentBalanceCop,
    required int amountCop,
  }) {
    return currentBalanceCop - amountCop;
  }

  int calculateBalanceAfterCancellation({
    required int currentBalanceCop,
    required int originalSubscribedAmountCop,
  }) {
    return currentBalanceCop + originalSubscribedAmountCop;
  }
}
