import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/fund_holding.dart';
import 'package:amaris_test/core/domain/models/portfolio_snapshot.dart';
import 'package:amaris_test/core/ui/formatters/app_formatters.dart';
import 'package:amaris_test/core/ui/theme/app_radius.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/core/ui/widgets/async_state_widgets.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_queries.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/state/user_preferences_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(activeHoldingsProvider);
    final userPreferences =
        ref.watch(userPreferencesNotifierProvider).valueOrNull ??
        UserPreferences.defaults;

    ref.listen<AsyncValue<PortfolioSnapshot>>(portfolioAsyncNotifierProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is PortfolioFailure
              ? error.friendlyMessage
              : 'Operation failed';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    return ListView(
      children: [
        _SummarySection(holdings: holdings),
        const SizedBox(height: AppSpacing.md),
        _HoldingsSection(
          holdings: holdings,
          onRetry: () => ref.invalidate(activeHoldingsProvider),
          onCancelHolding: (holding) async {
            if (userPreferences.requireCancellationConfirmation) {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Cancel this subscription?'),
                  content: Text(
                    'You will stop contributions to ${holding.fundName} and ${formatCop(holding.subscribedAmountCop)} will return to your available balance.',
                  ),
                  actions: [
                    Semantics(
                      button: true,
                      label: 'Keep current subscription to ${holding.fundName}',
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Keep subscription'),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Confirm cancellation for ${holding.fundName}',
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(
                            dialogContext,
                          ).colorScheme.error,
                          foregroundColor: Theme.of(
                            dialogContext,
                          ).colorScheme.onError,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Cancel subscription'),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed != true) {
                return;
              }
            }

            await ref
                .read(portfolioAsyncNotifierProvider.notifier)
                .cancelHolding(holdingId: holding.id);

            if (!context.mounted) {
              return;
            }

            final state = ref.read(portfolioAsyncNotifierProvider);
            if (!state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${holding.fundName} canceled')),
              );
            }
          },
        ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.holdings});

  final AsyncValue<List<FundHolding>> holdings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPortfolioValue = holdings.when(
      data: (items) {
        final total = items.fold<int>(
          0,
          (sum, holding) => sum + holding.subscribedAmountCop,
        );
        return formatCop(total);
      },
      loading: () => 'Loading...',
      error: (error, stack) => 'Unavailable',
    );
    final activeHoldingsLabel = holdings.when(
      data: (items) => '${items.length} active subscriptions',
      loading: () => 'Checking subscriptions',
      error: (error, stack) => 'Subscriptions unavailable',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total portfolio',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(totalPortfolioValue, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _SummaryPill(
                  icon: Icons.stacked_line_chart,
                  label: activeHoldingsLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingsSection extends StatelessWidget {
  const _HoldingsSection({
    required this.holdings,
    required this.onRetry,
    required this.onCancelHolding,
  });

  final AsyncValue<List<FundHolding>> holdings;
  final VoidCallback onRetry;
  final ValueChanged<FundHolding> onCancelHolding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Holdings by fund',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Review your active subscriptions and cancel when needed.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        holdings.when(
          data: (items) {
            if (items.isEmpty) {
              return const _HoldingsStateCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No active holdings yet',
                message:
                    'Your subscribed funds will appear here once you complete your first subscription.',
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      _HoldingCard(
                        holding: items[index],
                        traversalOrder: index + 1,
                        onCancel: () => onCancelHolding(items[index]),
                      ),
                      if (index < items.length - 1)
                        const Divider(height: AppSpacing.lg),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const CenteredLoadingIndicator(
            message: 'Loading active holdings...',
          ),
          error: (error, stack) => CenteredErrorText(
            title: 'Could not load holdings',
            message: 'Please try again in a moment.',
            onRetry: onRetry,
          ),
        ),
      ],
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({
    required this.holding,
    required this.traversalOrder,
    required this.onCancel,
  });

  final FundHolding holding;
  final int traversalOrder;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label:
          'Holding in ${holding.fundName}, amount ${formatCop(holding.subscribedAmountCop)}.',
      child: Row(
        children: [
          _HoldingTag(label: _holdingTagLabel(holding.fundName)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.fundName,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatCop(holding.subscribedAmountCop),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FocusTraversalOrder(
            order: NumericFocusOrder(traversalOrder.toDouble()),
            child: Semantics(
              button: true,
              label: 'Cancel subscription for ${holding.fundName}',
              child: OutlinedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _HoldingTag extends StatelessWidget {
  const _HoldingTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _HoldingsStateCard extends StatelessWidget {
  const _HoldingsStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _holdingTagLabel(String fundName) {
  final normalized = fundName.toUpperCase();
  if (normalized.contains('FIC')) {
    return 'FIC';
  }
  if (normalized.contains('FPV')) {
    return 'FPV';
  }

  return 'FUND';
}
