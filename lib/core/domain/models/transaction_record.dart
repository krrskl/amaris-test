import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_record.freezed.dart';
part 'transaction_record.g.dart';

enum TransactionType { subscription, cancellation }

enum NotificationMethod { email, sms, none }

@freezed
abstract class TransactionRecord with _$TransactionRecord {
  const factory TransactionRecord({
    required String id,
    required DateTime timestamp,
    required String fundName,
    required int amountCop,
    required TransactionType type,
    required NotificationMethod notificationMethod,
  }) = _TransactionRecord;

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      _$TransactionRecordFromJson(json);
}
