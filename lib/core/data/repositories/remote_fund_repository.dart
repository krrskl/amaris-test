import 'package:amaris_test/core/config/app_endpoints.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/repositories/fund_repository.dart';
import 'package:dio/dio.dart';

class RemoteFundRepository implements FundRepository {
  RemoteFundRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<Fund>> getFunds() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppEndpoints.fundsPath,
      );
      final payload = response.data;
      final rawFunds = payload?['data'];
      if (rawFunds is! List<dynamic>) {
        throw const FormatException('Invalid funds payload.');
      }

      return rawFunds.map((item) => _mapFund(item)).toList(growable: false);
    } on DioException catch (error) {
      final reason = error.message ?? error.type.name;
      throw Exception('Unable to load funds from API: $reason');
    }
  }

  Fund _mapFund(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Fund entry must be a JSON object.');
    }

    final id = raw['id']?.toString();
    final name = raw['name']?.toString();
    final description = raw['description']?.toString();
    final minimumAmountCop = _parseMinimumAmount(raw['minimumAmountCop']);
    final category = _parseCategory(raw['category']);

    if (id == null || name == null || description == null) {
      throw const FormatException('Fund payload is missing required fields.');
    }

    return Fund(
      id: id,
      name: name,
      minimumAmountCop: minimumAmountCop,
      category: category,
      description: description,
    );
  }

  int _parseMinimumAmount(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }

    throw const FormatException('minimumAmountCop must be numeric.');
  }

  FundCategory _parseCategory(dynamic value) {
    if (value is! String) {
      throw const FormatException('Fund category must be a string.');
    }

    return switch (value.toLowerCase()) {
      'fpv' => FundCategory.fpv,
      'fic' => FundCategory.fic,
      _ => throw FormatException('Unknown fund category: $value'),
    };
  }
}
