import 'package:flutter/material.dart';

class AppDestination {
  const AppDestination({
    required this.label,
    required this.path,
    required this.icon,
    required this.title,
  });

  final String label;
  final String path;
  final IconData icon;
  final String title;
}

abstract final class AppRoutePaths {
  static const home = '/home';
  static const funds = '/funds';
  static const transactions = '/transactions';
  static const settings = '/settings';
}

const appDestinations = <AppDestination>[
  AppDestination(
    label: 'Home',
    path: AppRoutePaths.home,
    icon: Icons.home_outlined,
    title: 'Portfolio Home',
  ),
  AppDestination(
    label: 'Funds',
    path: AppRoutePaths.funds,
    icon: Icons.account_balance_wallet_outlined,
    title: 'Fund Catalog',
  ),
  AppDestination(
    label: 'Transactions',
    path: AppRoutePaths.transactions,
    icon: Icons.receipt_long_outlined,
    title: 'Transactions',
  ),
  AppDestination(
    label: 'Settings',
    path: AppRoutePaths.settings,
    icon: Icons.settings_outlined,
    title: 'Settings',
  ),
];

int destinationIndexFromLocation(String location) {
  for (var index = 0; index < appDestinations.length; index++) {
    if (location.startsWith(appDestinations[index].path)) {
      return index;
    }
  }

  return 0;
}
