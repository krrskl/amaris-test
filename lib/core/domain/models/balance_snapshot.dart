import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_snapshot.freezed.dart';
part 'balance_snapshot.g.dart';

@freezed
abstract class BalanceSnapshot with _$BalanceSnapshot {
  const factory BalanceSnapshot({
    required int amountCop,
    required DateTime updatedAt,
  }) = _BalanceSnapshot;

  factory BalanceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$BalanceSnapshotFromJson(json);
}
