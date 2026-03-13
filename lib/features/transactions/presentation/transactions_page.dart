import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/ui/formatters/app_formatters.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/core/ui/widgets/async_state_widgets.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_queries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Latest subscriptions and cancellations',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: transactions.when(
            data: (items) {
              if (items.isEmpty) {
                return const _TransactionsEmptyState();
              }

              return _TransactionsList(items: items);
            },
            loading: () => const CenteredLoadingIndicator(),
            error: (error, stack) =>
                const CenteredErrorText(message: 'Failed to load history'),
          ),
        ),
      ],
    );
  }
}

class _TransactionsEmptyState extends StatelessWidget {
  const _TransactionsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No transactions yet',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your buy and sell activity will appear here once you make your first movement.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({required this.items});

  final List<TransactionRecord> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _TransactionCard(record: items[index]),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.record});

  final TransactionRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.fundName,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _metadataLabel(record),
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatTimestamp(record.timestamp),
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              formatCop(record.amountCop),
              style: textTheme.titleSmall?.copyWith(
                color: _amountColor(theme.colorScheme, record.type),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _amountColor(ColorScheme colorScheme, TransactionType type) {
  return switch (type) {
    TransactionType.subscription => colorScheme.primary,
    TransactionType.cancellation => colorScheme.error,
  };
}

String _typeLabel(TransactionType type) {
  return switch (type) {
    TransactionType.subscription => 'Subscription',
    TransactionType.cancellation => 'Cancellation',
  };
}

String _notificationLabel(NotificationMethod method) {
  return switch (method) {
    NotificationMethod.email => 'Email',
    NotificationMethod.sms => 'SMS',
    NotificationMethod.none => 'No notification',
  };
}

String _metadataLabel(TransactionRecord record) {
  final typeLabel = _typeLabel(record.type);

  if (record.type == TransactionType.cancellation) {
    return typeLabel;
  }

  return '$typeLabel - ${_notificationLabel(record.notificationMethod)}';
}
