import 'package:amaris_test/core/state/providers.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return transactions.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No transactions found'));
        }

        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final record = items[index];
            return Card(
              child: ListTile(
                title: Text(record.fundName),
                subtitle: Text(
                  '${record.type.name.toUpperCase()} - ${record.notificationMethod.name.toUpperCase()}',
                ),
                trailing: Text('COP ${record.amountCop}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          const Center(child: Text('Failed to load history')),
    );
  }
}
