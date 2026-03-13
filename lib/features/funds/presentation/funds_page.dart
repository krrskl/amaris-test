import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/ui/formatters/app_formatters.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/core/ui/widgets/async_state_widgets.dart';
import 'package:amaris_test/features/funds/state/funds_providers.dart';
import 'package:amaris_test/features/funds/state/subscription_dialog_form_provider.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FundsPage extends ConsumerWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(filteredFundsProvider);
    final hasActiveFilters = ref.watch(hasActiveFundFiltersProvider);
    final availableBalanceCop = ref.watch(availableBalanceForFundsProvider);
    final preferredNotificationMethod = ref.watch(
      preferredNotificationMethodForFundsProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All funds', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        const _FundsFilters(),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: funds.when(
            data: (items) {
              if (items.isEmpty) {
                return _FundsEmptyState(
                  hasActiveFilters: hasActiveFilters,
                  onClearFilters: () {
                    ref.read(fundSearchQueryProvider.notifier).state = '';
                    ref.read(selectedFundTypeFilterProvider.notifier).state =
                        FundTypeFilter.all;
                  },
                );
              }

              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final fund = items[index];
                  return _FundCard(
                    fund: fund,
                    categoryLabel: _labelForCategory(fund.category),
                    traversalOrder: index + 1,
                    isAffordable:
                        availableBalanceCop == null ||
                        fund.minimumAmountCop <= availableBalanceCop,
                    onSubscribe: () => _showSubscriptionDialog(
                      context,
                      ref,
                      fund,
                      preferredNotificationMethod,
                    ),
                  );
                },
              );
            },
            loading: () => const CenteredLoadingIndicator(
              message: 'Loading available funds...',
            ),
            error: (error, stack) => CenteredErrorText(
              title: 'We could not load funds',
              message: 'Check your connection and try again.',
              onRetry: () => ref.invalidate(filteredFundsProvider),
            ),
          ),
        ),
      ],
    );
  }

  String _labelForCategory(FundCategory category) {
    return switch (category) {
      FundCategory.fpv => 'FPV',
      FundCategory.fic => 'FIC',
    };
  }

  Future<void> _showSubscriptionDialog(
    BuildContext context,
    WidgetRef ref,
    Fund fund,
    NotificationMethod preferredNotificationMethod,
  ) async {
    final wasSubmitted = await showDialog<bool>(
      context: context,
      builder: (context) => _SubscriptionDialog(
        fund: fund,
        initialNotificationMethod: preferredNotificationMethod,
      ),
    );

    if (wasSubmitted == true && context.mounted) {
      final state = ref.read(portfolioAsyncNotifierProvider);
      if (!state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Subscription completed')));
      }
    }
  }
}

class _FundsFilters extends ConsumerWidget {
  const _FundsFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedFundTypeFilterProvider);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              hintText: 'Search funds by name',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                ref.read(fundSearchQueryProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Fund type', style: textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<FundTypeFilter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<FundTypeFilter>(
                    value: FundTypeFilter.all,
                    label: Text('ALL'),
                  ),
                  ButtonSegment<FundTypeFilter>(
                    value: FundTypeFilter.fpv,
                    label: Text('FPV'),
                  ),
                  ButtonSegment<FundTypeFilter>(
                    value: FundTypeFilter.fic,
                    label: Text('FIC'),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) {
                    return;
                  }

                  ref.read(selectedFundTypeFilterProvider.notifier).state =
                      selection.first;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  const _FundCard({
    required this.fund,
    required this.categoryLabel,
    required this.traversalOrder,
    required this.isAffordable,
    required this.onSubscribe,
  });

  final Fund fund;
  final String categoryLabel;
  final int traversalOrder;
  final bool isAffordable;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label:
          'Fund ${fund.name}. Minimum ${formatCop(fund.minimumAmountCop)}. Type $categoryLabel.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fund.name,
                style: textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minimum',
                        style: textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formatCop(fund.minimumAmountCop),
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        fund.category.name.toUpperCase(),
                        style: textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: _SubscribeActionButton(
                  fundName: fund.name,
                  traversalOrder: traversalOrder,
                  isAffordable: isAffordable,
                  onSubscribe: onSubscribe,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FundsEmptyState extends StatelessWidget {
  const _FundsEmptyState({
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
                    Icons.search_off,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  hasActiveFilters ? 'No matching funds' : 'No funds available',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hasActiveFilters
                      ? 'Update your search or filter type to find a fund.'
                      : 'Funds will appear here as soon as data is available.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.tonal(
                    onPressed: onClearFilters,
                    child: const Text('Clear filters and show all funds'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscribeActionButton extends StatelessWidget {
  const _SubscribeActionButton({
    required this.fundName,
    required this.traversalOrder,
    required this.isAffordable,
    required this.onSubscribe,
  });

  final String fundName;
  final int traversalOrder;
  final bool isAffordable;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    if (isAffordable) {
      return FocusTraversalOrder(
        order: NumericFocusOrder(traversalOrder.toDouble()),
        child: Semantics(
          button: true,
          label: 'Subscribe to $fundName',
          child: FilledButton(
            onPressed: onSubscribe,
            child: const Text('Subscribe'),
          ),
        ),
      );
    }

    final tooltipKey = GlobalKey<TooltipState>();
    return FocusTraversalOrder(
      order: NumericFocusOrder(traversalOrder.toDouble()),
      child: Tooltip(
        key: tooltipKey,
        message: 'Insufficient balance',
        triggerMode: TooltipTriggerMode.manual,
        child: Semantics(
          button: true,
          enabled: false,
          label:
              'Subscribe to $fundName unavailable due to insufficient balance',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => tooltipKey.currentState?.ensureTooltipVisible(),
            child: const FilledButton(
              onPressed: null,
              child: Text('Subscribe'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionDialog extends ConsumerWidget {
  const _SubscriptionDialog({
    required this.fund,
    required this.initialNotificationMethod,
  });

  final Fund fund;
  final NotificationMethod initialNotificationMethod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formProvider = subscriptionDialogFormProvider(
      initialNotificationMethod: initialNotificationMethod,
    );
    final form = ref.watch(formProvider);

    return AlertDialog(
      title: Text('Subscribe to ${fund.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (COP)',
              hintText: '50000',
            ),
            onChanged: ref.read(formProvider.notifier).setAmountInput,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<NotificationMethod>(
            key: ValueKey(form.selectedNotification),
            initialValue: form.selectedNotification,
            decoration: const InputDecoration(labelText: 'Notification method'),
            items: const [
              DropdownMenuItem(
                value: NotificationMethod.none,
                child: Text('Select one'),
              ),
              DropdownMenuItem(
                value: NotificationMethod.email,
                child: Text('Email'),
              ),
              DropdownMenuItem(
                value: NotificationMethod.sms,
                child: Text('SMS'),
              ),
            ],
            onChanged: (value) {
              ref
                  .read(formProvider.notifier)
                  .setNotificationMethod(value ?? NotificationMethod.none);
            },
          ),
          if (form.inlineErrorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              form.inlineErrorMessage!,
              key: const Key('subscription-dialog-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        Semantics(
          button: true,
          label: 'Close subscription dialog',
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ),
        Semantics(
          button: true,
          label: 'Confirm subscription to ${fund.name}',
          child: FilledButton(
            onPressed: () async {
              final wasSubmitted = await ref
                  .read(formProvider.notifier)
                  .confirmSubscription(fund: fund);

              if (wasSubmitted && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Confirm'),
          ),
        ),
      ],
    );
  }
}
