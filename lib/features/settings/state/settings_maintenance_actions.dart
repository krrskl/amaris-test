import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:amaris_test/features/settings/state/user_preferences_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_maintenance_actions.g.dart';

final settingsMaintenanceActionsProvider = Provider<SettingsMaintenanceActions>(
  SettingsMaintenanceActions.new,
);

class SettingsMaintenanceActions {
  const SettingsMaintenanceActions(this._ref);

  final Ref _ref;

  Future<void> resetPortfolioData() {
    return _ref
        .read(portfolioAsyncNotifierProvider.notifier)
        .resetPortfolioData();
  }

  Future<void> resetPreferences() {
    return _ref
        .read(userPreferencesNotifierProvider.notifier)
        .resetPreferences();
  }

  Future<void> clearAllLocalData() async {
    await resetPortfolioData();
    await resetPreferences();
  }
}

class SettingsMaintenanceState {
  const SettingsMaintenanceState({
    this.isResettingPortfolio = false,
    this.isResettingPreferences = false,
  });

  final bool isResettingPortfolio;
  final bool isResettingPreferences;

  SettingsMaintenanceState copyWith({
    bool? isResettingPortfolio,
    bool? isResettingPreferences,
  }) {
    return SettingsMaintenanceState(
      isResettingPortfolio: isResettingPortfolio ?? this.isResettingPortfolio,
      isResettingPreferences:
          isResettingPreferences ?? this.isResettingPreferences,
    );
  }
}

@riverpod
class SettingsMaintenanceController extends _$SettingsMaintenanceController {
  @override
  SettingsMaintenanceState build() {
    return const SettingsMaintenanceState();
  }

  Future<void> resetPortfolioData() async {
    if (state.isResettingPortfolio) {
      return;
    }

    state = state.copyWith(isResettingPortfolio: true);
    try {
      await ref.read(settingsMaintenanceActionsProvider).resetPortfolioData();
    } finally {
      state = state.copyWith(isResettingPortfolio: false);
    }
  }

  Future<void> resetPreferences() async {
    if (state.isResettingPreferences) {
      return;
    }

    state = state.copyWith(isResettingPreferences: true);
    try {
      await ref.read(settingsMaintenanceActionsProvider).resetPreferences();
    } finally {
      state = state.copyWith(isResettingPreferences: false);
    }
  }
}
