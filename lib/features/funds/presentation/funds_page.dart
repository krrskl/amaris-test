import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/state/providers.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FundsPage extends ConsumerWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);

    return funds.when(
      data: (items) => ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final fund = items[index];
          return Card(
            child: ListTile(
              title: Text(fund.name),
              subtitle: Text(
                '${_labelForCategory(fund.category)} - Min COP ${fund.minimumAmountCop}',
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          const Center(child: Text('Failed to load funds')),
    );
  }

  String _labelForCategory(FundCategory category) {
    return switch (category) {
      FundCategory.fpv => 'FPV',
      FundCategory.fic => 'FIC',
    };
  }
}
