import 'package:amaris_test/core/state/providers.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);
    final transactions = ref.watch(transactionsProvider);

    return ListView(
      children: [
        Text(
          'Welcome to BTG Pactual',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: ListTile(
            title: const Text('Available Funds'),
            subtitle: funds.when(
              data: (items) => Text('${items.length} catalog entries'),
              loading: () => const Text('Loading...'),
              error: (error, stack) => const Text('Error loading funds'),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Recent Transactions'),
            subtitle: transactions.when(
              data: (items) => Text('${items.length} records in local ledger'),
              loading: () => const Text('Loading...'),
              error: (error, stack) => const Text('Error loading transactions'),
            ),
          ),
        ),
      ],
    );
  }
}
