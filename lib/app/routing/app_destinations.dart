import 'package:amaris_test/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class AppDestination {
  const AppDestination({
    required this.labelBuilder,
    required this.path,
    required this.icon,
    required this.titleBuilder,
  });

  final String Function(Translations) labelBuilder;
  final String path;
  final IconData icon;
  final String Function(Translations) titleBuilder;

  String label(Translations t) => labelBuilder(t);

  String title(Translations t) => titleBuilder(t);
}

abstract final class AppRoutePaths {
  static const home = '/home';
  static const funds = '/funds';
  static const transactions = '/transactions';
  static const settings = '/settings';
}

final appDestinations = <AppDestination>[
  AppDestination(
    labelBuilder: _homeLabel,
    path: AppRoutePaths.home,
    icon: Icons.home_outlined,
    titleBuilder: _homeTitle,
  ),
  AppDestination(
    labelBuilder: _fundsLabel,
    path: AppRoutePaths.funds,
    icon: Icons.account_balance_wallet_outlined,
    titleBuilder: _fundsTitle,
  ),
  AppDestination(
    labelBuilder: _transactionsLabel,
    path: AppRoutePaths.transactions,
    icon: Icons.receipt_long_outlined,
    titleBuilder: _transactionsTitle,
  ),
  AppDestination(
    labelBuilder: _settingsLabel,
    path: AppRoutePaths.settings,
    icon: Icons.settings_outlined,
    titleBuilder: _settingsTitle,
  ),
];

String _homeLabel(Translations t) => t.nav.homeLabel;
String _homeTitle(Translations t) => t.nav.homeTitle;
String _fundsLabel(Translations t) => t.nav.fundsLabel;
String _fundsTitle(Translations t) => t.nav.fundsTitle;
String _transactionsLabel(Translations t) => t.nav.transactionsLabel;
String _transactionsTitle(Translations t) => t.nav.transactionsTitle;
String _settingsLabel(Translations t) => t.nav.settingsLabel;
String _settingsTitle(Translations t) => t.nav.settingsTitle;

int destinationIndexFromLocation(String location) {
  for (var index = 0; index < appDestinations.length; index++) {
    if (location.startsWith(appDestinations[index].path)) {
      return index;
    }
  }

  return 0;
}
