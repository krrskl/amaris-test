import 'package:amaris_test/app/routing/app_destinations.dart';
import 'package:amaris_test/core/state/providers.dart';
import 'package:amaris_test/core/ui/breakpoints/app_breakpoints.dart';
import 'package:amaris_test/core/ui/layout/adaptive_navigation.dart';
import 'package:amaris_test/core/ui/layout/responsive_page_container.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/core/ui/theme/app_widths.dart';
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

    final pageBody = ResponsivePageContainer(child: child);

    return Scaffold(
      appBar: AppBar(
        title: Text(appDestinations[currentIndex].title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _BalanceBadge(ref: ref),
          ),
        ],
      ),
      body: switch (size) {
        AppWindowSize.compact => pageBody,
        AppWindowSize.medium => Row(
          children: [
            AdaptiveNavigation(
              currentIndex: currentIndex,
              onSelect: (index) {
                context.go(appDestinations[index].path);
              },
              variant: AdaptiveNavigationVariant.rail,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pageBody),
          ],
        ),
        AppWindowSize.expanded => Row(
          children: [
            SizedBox(
              width: AppWidths.sidePanel,
              child: AdaptiveNavigation(
                currentIndex: currentIndex,
                onSelect: (index) {
                  context.go(appDestinations[index].path);
                },
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
        ),
      },
      bottomNavigationBar: size == AppWindowSize.compact
          ? AdaptiveNavigation(
              currentIndex: currentIndex,
              onSelect: (index) {
                context.go(appDestinations[index].path);
              },
              variant: AdaptiveNavigationVariant.bottom,
            )
          : null,
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceSnapshotProvider);

    return balance.when(
      data: (snapshot) =>
          Chip(label: Text('Available: COP ${snapshot.amountCop}')),
      loading: () => const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => const Chip(label: Text('Balance unavailable')),
    );
  }
}

class _ExpandedContextPanel extends ConsumerWidget {
  const _ExpandedContextPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);
    final transactions = ref.watch(transactionsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Stats', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _StatTile(
            label: 'Funds',
            value: funds.when(
              data: (items) => '${items.length}',
              loading: () => '...',
              error: (error, stack) => '-',
            ),
          ),
          _StatTile(
            label: 'Transactions',
            value: transactions.when(
              data: (items) => '${items.length}',
              loading: () => '...',
              error: (error, stack) => '-',
            ),
          ),
        ],
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
