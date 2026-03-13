import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fund_holding.freezed.dart';
part 'fund_holding.g.dart';

@freezed
abstract class FundHolding with _$FundHolding {
  const factory FundHolding({
    required String id,
    required String fundId,
    required String fundName,
    required int subscribedAmountCop,
    required NotificationMethod notificationMethod,
    required DateTime subscribedAt,
  }) = _FundHolding;

  factory FundHolding.fromJson(Map<String, dynamic> json) =>
      _$FundHoldingFromJson(json);
}
