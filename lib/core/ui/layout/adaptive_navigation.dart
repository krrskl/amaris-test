import 'package:amaris_test/i18n/strings.g.dart';
import 'package:amaris_test/app/routing/app_destinations.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    required this.currentIndex,
    required this.onSelect,
    required this.variant,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final AdaptiveNavigationVariant variant;

  @override
  Widget build(BuildContext context) {
    final tr = context.t;

    switch (variant) {
      case AdaptiveNavigationVariant.bottom:
        return NavigationBar(
          key: const Key('nav-bottom'),
          selectedIndex: currentIndex,
          onDestinationSelected: onSelect,
          destinations: appDestinations
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  label: item.label(tr),
                ),
              )
              .toList(),
        );
      case AdaptiveNavigationVariant.rail:
        return NavigationRail(
          key: const Key('nav-rail'),
          selectedIndex: currentIndex,
          onDestinationSelected: onSelect,
          labelType: NavigationRailLabelType.all,
          destinations: appDestinations
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label(tr)),
                ),
              )
              .toList(),
        );
      case AdaptiveNavigationVariant.sidePanel:
        return ColoredBox(
          key: const Key('nav-sidepanel'),
          color: Theme.of(context).colorScheme.surface,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (var index = 0; index < appDestinations.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    selected: index == currentIndex,
                    onTap: () => onSelect(index),
                    leading: Icon(appDestinations[index].icon),
                    title: Text(appDestinations[index].label(tr)),
                  ),
                ),
            ],
          ),
        );
    }
  }
}

enum AdaptiveNavigationVariant { bottom, rail, sidePanel }
