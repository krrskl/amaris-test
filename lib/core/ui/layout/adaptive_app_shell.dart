import 'package:amaris_test/app/routing/app_destinations.dart';
import 'package:amaris_test/core/ui/breakpoints/app_breakpoints.dart';
import 'package:amaris_test/core/ui/formatters/app_formatters.dart';
import 'package:amaris_test/core/ui/layout/adaptive_navigation.dart';
import 'package:amaris_test/core/ui/layout/responsive_page_container.dart';
import 'package:amaris_test/core/ui/theme/app_radius.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/core/ui/theme/app_widths.dart';
import 'package:amaris_test/features/funds/state/funds_providers.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_queries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdaptiveAppShell extends ConsumerWidget {
  const AdaptiveAppShell({
    required this.currentLocation,
    required this.child,
    super.key,
  });

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = AppBreakpoints.fromContext(context);
    final currentIndex = destinationIndexFromLocation(currentLocation);
    void onSelectDestination(int index) {
      context.go(appDestinations[index].path);
    }

    final pageBody = ResponsivePageContainer(child: child);

    return Scaffold(
      appBar: AppBar(
        title: Text(appDestinations[currentIndex].title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: const _BalanceBadge(),
          ),
        ],
      ),
      body: switch (size) {
        AppWindowSize.compact => pageBody,
        AppWindowSize.medium => _MediumShellBody(
          currentIndex: currentIndex,
          pageBody: pageBody,
          onSelectDestination: onSelectDestination,
        ),
        AppWindowSize.expanded => _ExpandedShellBody(
          currentIndex: currentIndex,
          pageBody: pageBody,
          onSelectDestination: onSelectDestination,
        ),
      },
      bottomNavigationBar: size == AppWindowSize.compact
          ? AdaptiveNavigation(
              currentIndex: currentIndex,
              onSelect: onSelectDestination,
              variant: AdaptiveNavigationVariant.bottom,
            )
          : null,
    );
  }
}

class _MediumShellBody extends StatelessWidget {
  const _MediumShellBody({
    required this.currentIndex,
    required this.pageBody,
    required this.onSelectDestination,
  });

  final int currentIndex;
  final Widget pageBody;
  final ValueChanged<int> onSelectDestination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AdaptiveNavigation(
          currentIndex: currentIndex,
          onSelect: onSelectDestination,
          variant: AdaptiveNavigationVariant.rail,
        ),
        const VerticalDivider(width: 1),
        Expanded(child: pageBody),
      ],
    );
  }
}

class _ExpandedShellBody extends StatelessWidget {
  const _ExpandedShellBody({
    required this.currentIndex,
    required this.pageBody,
    required this.onSelectDestination,
  });

  final int currentIndex;
  final Widget pageBody;
  final ValueChanged<int> onSelectDestination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppWidths.sidePanel,
          child: AdaptiveNavigation(
            currentIndex: currentIndex,
            onSelect: onSelectDestination,
            variant: AdaptiveNavigationVariant.sidePanel,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: pageBody),
        const VerticalDivider(width: 1),
        const SizedBox(
          width: AppWidths.contextPanel,
          child: _ExpandedContextPanel(),
        ),
      ],
    );
  }
}

class _BalanceBadge extends ConsumerWidget {
  const _BalanceBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceSnapshotProvider);

    return balance.when(
      data: (snapshot) => _BalanceBadgeSurface(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Available',
        value: formatCop(snapshot.amountCop),
      ),
      loading: () => const _BalanceBadgeLoading(),
      error: (error, stack) => const _BalanceBadgeSurface(
        icon: Icons.error_outline,
        label: 'Portfolio',
        value: 'Balance unavailable',
      ),
    );
  }
}

class _BalanceBadgeLoading extends StatelessWidget {
  const _BalanceBadgeLoading();

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
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: const SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _BalanceBadgeSurface extends StatelessWidget {
  const _BalanceBadgeSurface({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedContextPanel extends ConsumerWidget {
  const _ExpandedContextPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);
    final transactions = ref.watch(transactionsProvider);
    final holdings = ref.watch(activeHoldingsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Stats', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _AsyncCountStatTile(label: 'Funds', value: funds),
          _AsyncCountStatTile(label: 'Transactions', value: transactions),
          _AsyncCountStatTile(label: 'Holdings', value: holdings),
        ],
      ),
    );
  }
}

class _AsyncCountStatTile<T> extends StatelessWidget {
  const _AsyncCountStatTile({required this.label, required this.value});

  final String label;
  final AsyncValue<List<T>> value;

  @override
  Widget build(BuildContext context) {
    return _StatTile(
      label: label,
      value: value.when(
        data: (items) => '${items.length}',
        loading: () => '...',
        error: (error, stack) => '-',
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(dense: true, title: Text(label), trailing: Text(value)),
    );
  }
}
