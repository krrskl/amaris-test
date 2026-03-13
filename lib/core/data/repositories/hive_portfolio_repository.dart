import 'dart:convert';

import 'package:amaris_test/core/data/persistence/persistence_constants.dart';
import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/domain/repositories/portfolio_repository.dart';
import 'package:hive_ce/hive.dart';

class HivePortfolioRepository implements PortfolioRepository {
  HivePortfolioRepository({required Box<String> box}) : _box = box;

  final Box<String> _box;

  /// Contract:
  /// - Missing snapshot -> seed and return [PortfolioSnapshot.initial].
  /// - Any read/deserialize/write failure -> throw [PortfolioFailure.persistence].
  ///
  /// Portfolio persistence is critical and does not silently fallback on
  /// corrupted payloads.
  @override
  Future<PortfolioSnapshot> loadPortfolio() async {
    try {
      final raw = _box.get(PersistenceKeys.portfolioSnapshot);
      if (raw == null || raw.isEmpty) {
        final initial = PortfolioSnapshot.initial();
        await savePortfolio(initial);
        return initial;
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return PortfolioSnapshot.fromJson(decoded);
    } on PortfolioFailure {
      rethrow;
    } on Object catch (error) {
      throw PortfolioFailure.persistence(details: error.toString());
    }
  }

  @override
  Future<void> savePortfolio(PortfolioSnapshot snapshot) async {
    try {
      final raw = jsonEncode(snapshot.toJson());
      await _box.put(PersistenceKeys.portfolioSnapshot, raw);
    } on Object catch (error) {
      throw PortfolioFailure.persistence(details: error.toString());
    }
  }

  @override
  Future<void> appendTransaction(TransactionRecord record) async {
    try {
      final raw = _box.get(PersistenceKeys.portfolioSnapshot);
      final now = DateTime.now().toUtc();

      if (raw == null || raw.isEmpty) {
        final seeded = PortfolioSnapshot.initial().copyWith(
          transactions: <TransactionRecord>[record],
          updatedAt: now,
        );
        await savePortfolio(seeded);
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Portfolio payload must be a JSON object');
      }

      final transactions = decoded['transactions'];
      if (transactions is! List<dynamic>) {
        throw const FormatException(
          'Portfolio transactions must be a JSON list',
        );
      }

      final next = Map<String, dynamic>.from(decoded)
        ..['transactions'] = <dynamic>[...transactions, record.toJson()]
        ..['updatedAt'] = now.toIso8601String();

      await _box.put(PersistenceKeys.portfolioSnapshot, jsonEncode(next));
    } on PortfolioFailure {
      rethrow;
    } on Object catch (error) {
      throw PortfolioFailure.persistence(details: error.toString());
    }
  }
}
