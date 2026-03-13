import 'dart:async';

import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/ui/theme/app_radius.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/state/settings_maintenance_actions.dart';
import 'package:amaris_test/features/settings/state/user_preferences_notifier.dart';
import 'package:amaris_test/features/settings/state/user_preferences_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPreferences = ref.watch(currentUserPreferencesProvider);
    final isPersistingPreferences = ref.watch(
      isPersistingUserPreferencesProvider,
    );
    final maintenanceState = ref.watch(settingsMaintenanceControllerProvider);

    ref.listen<AsyncValue<UserPreferences>>(userPreferencesNotifierProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save settings: $error')),
          );
        },
      );
    });

    final controlsEnabled = !isPersistingPreferences;

    return ListView(
      children: [
        _SectionCard(
          title: 'User preferences',
          description:
              'Control default notification method and confirmation behavior.',
          child: Column(
            children: [
              DropdownButtonFormField<NotificationMethod>(
                key: ValueKey(currentPreferences.preferredNotificationMethod),
                initialValue: currentPreferences.preferredNotificationMethod,
                decoration: const InputDecoration(
                  labelText: 'Default notification method',
                ),
                items: const [
                  DropdownMenuItem(
                    value: NotificationMethod.email,
                    child: Text('Email'),
                  ),
                  DropdownMenuItem(
                    value: NotificationMethod.sms,
                    child: Text('SMS'),
                  ),
                  DropdownMenuItem(
                    value: NotificationMethod.none,
                    child: Text('Ask me each time'),
                  ),
                ],
                onChanged: !controlsEnabled
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        unawaited(
                          ref
                              .read(userPreferencesNotifierProvider.notifier)
                              .setPreferredNotificationMethod(value),
                        );
                      },
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Require confirmation before cancellation'),
                subtitle: const Text(
                  'Show a confirmation dialog before canceling a subscription.',
                ),
                value: currentPreferences.requireCancellationConfirmation,
                onChanged: !controlsEnabled
                    ? null
                    : (value) {
                        unawaited(
                          ref
                              .read(userPreferencesNotifierProvider.notifier)
                              .setRequireCancellationConfirmation(value),
                        );
                      },
              ),
              if (isPersistingPreferences)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Danger zone',
          description:
              'These actions change local data immediately. Confirmation is required.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _DangerZoneHintBanner(),
              const SizedBox(height: AppSpacing.md),
              _DangerActionTile(
                icon: Icons.restart_alt,
                title: 'Reset portfolio data',
                subtitle:
                    'Removes all subscriptions and transaction history, then restores the initial balance.',
                isBusy: maintenanceState.isResettingPortfolio,
                focusOrder: 1,
                actionLabel: 'Reset portfolio',
                onPressed: () => _confirmAndResetPortfolio(context, ref),
              ),
              const SizedBox(height: AppSpacing.md),
              _DangerActionTile(
                icon: Icons.tune,
                title: 'Reset preferences',
                subtitle:
                    'Restores notification method and confirmation settings to defaults.',
                isBusy: maintenanceState.isResettingPreferences,
                focusOrder: 2,
                actionLabel: 'Reset preferences',
                onPressed: () => _confirmAndResetPreferences(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndResetPortfolio(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await _showDangerConfirmationDialog(
      context,
      title: 'Reset portfolio data?',
      message:
          'This removes holdings and transaction history from this device and resets your balance to COP 500000.',
      actionLabel: 'Reset portfolio',
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(settingsMaintenanceControllerProvider.notifier)
          .resetPortfolioData();
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text('Portfolio data reset')),
      );
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(SnackBar(content: Text('Reset failed: $error')));
    }
  }

  Future<void> _confirmAndResetPreferences(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await _showDangerConfirmationDialog(
      context,
      title: 'Reset preferences?',
      message:
          'This restores notification method, cancellation confirmation, and success snackbar settings.',
      actionLabel: 'Reset preferences',
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(settingsMaintenanceControllerProvider.notifier)
          .resetPreferences();
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text('Preferences reset')),
      );
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(SnackBar(content: Text('Reset failed: $error')));
    }
  }

  Future<bool?> _showDangerConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This action cannot be undone on this device.',
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                color: Theme.of(dialogContext).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Keep current data and close confirmation dialog',
            child: TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep data'),
            ),
          ),
          Semantics(
            button: true,
            label: actionLabel,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _DangerZoneHintBanner extends StatelessWidget {
  const _DangerZoneHintBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Use these actions only when you intentionally need a clean slate on this device.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerActionTile extends StatelessWidget {
  const _DangerActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isBusy,
    required this.focusOrder,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isBusy;
  final int focusOrder;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionStyle = OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.error,
      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.45)),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.22),
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.error),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FocusTraversalOrder(
              order: NumericFocusOrder(focusOrder.toDouble()),
              child: Semantics(
                button: true,
                enabled: !isBusy,
                label: '$actionLabel. $subtitle',
                child: OutlinedButton(
                  onPressed: isBusy ? null : onPressed,
                  style: actionStyle,
                  child: isBusy
                      ? SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.error,
                            ),
                          ),
                        )
                      : Text(actionLabel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
