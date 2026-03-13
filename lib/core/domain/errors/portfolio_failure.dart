sealed class PortfolioFailure implements Exception {
  const PortfolioFailure();

  String get friendlyMessage;

  const factory PortfolioFailure.minimumAmount({
    required int minimumAmountCop,
    required int attemptedAmountCop,
  }) = MinimumAmountFailure;

  const factory PortfolioFailure.insufficientBalance({
    required int balanceCop,
    required int attemptedAmountCop,
  }) = InsufficientBalanceFailure;

  const factory PortfolioFailure.notificationRequired() =
      NotificationRequiredFailure;

  const factory PortfolioFailure.holdingNotFound({required String holdingId}) =
      HoldingNotFoundFailure;

  const factory PortfolioFailure.persistence({required String details}) =
      PersistenceFailure;
}

final class MinimumAmountFailure extends PortfolioFailure {
  const MinimumAmountFailure({
    required this.minimumAmountCop,
    required this.attemptedAmountCop,
  });

  final int minimumAmountCop;
  final int attemptedAmountCop;

  @override
  String get friendlyMessage =>
      'Amount below minimum required: COP $minimumAmountCop';
}

final class InsufficientBalanceFailure extends PortfolioFailure {
  const InsufficientBalanceFailure({
    required this.balanceCop,
    required this.attemptedAmountCop,
  });

  final int balanceCop;
  final int attemptedAmountCop;

  @override
  String get friendlyMessage =>
      'Insufficient balance. Available COP $balanceCop, required COP $attemptedAmountCop';
}

final class NotificationRequiredFailure extends PortfolioFailure {
  const NotificationRequiredFailure();

  @override
  String get friendlyMessage =>
      'Notification method is required for subscriptions';
}

final class HoldingNotFoundFailure extends PortfolioFailure {
  const HoldingNotFoundFailure({required this.holdingId});

  final String holdingId;

  @override
  String get friendlyMessage => 'Selected holding does not exist anymore';
}

final class PersistenceFailure extends PortfolioFailure {
  const PersistenceFailure({required this.details});

  final String details;

  @override
  String get friendlyMessage =>
      'Could not persist portfolio state. Please retry.';
}
