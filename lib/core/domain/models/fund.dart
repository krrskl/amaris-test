import 'package:freezed_annotation/freezed_annotation.dart';

part 'fund.freezed.dart';
part 'fund.g.dart';

enum FundCategory { fpv, fic }

@freezed
abstract class Fund with _$Fund {
  const factory Fund({
    required String id,
    required String name,
    required int minimumAmountCop,
    required FundCategory category,
    required String description,
  }) = _Fund;

  factory Fund.fromJson(Map<String, dynamic> json) => _$FundFromJson(json);
}
