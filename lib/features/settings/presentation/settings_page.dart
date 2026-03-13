import 'dart:async';

import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/core/ui/theme/app_radius.dart';
import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/features/settings/domain/models/user_preferences.dart';
import 'package:amaris_test/features/settings/state/settings_maintenance_actions.dart';
import 'package:amaris_test/features/settings/state/user_preferences_notifier.dart';
import 'package:amaris_test/features/settings/state/user_preferences_selectors.dart';
import 'package:amaris_test/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.t;
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
            SnackBar(content: Text(tr.settings.saveError(error: '$error'))),
          );
        },
      );
    });

    final controlsEnabled = !isPersistingPreferences;

    return ListView(
      children: [
        _SectionCard(
          title: tr.settings.userPreferencesTitle,
          description: tr.settings.userPreferencesDescription,
          child: Column(
            children: [
              DropdownButtonFormField<PreferredLanguage>(
                key: ValueKey(currentPreferences.preferredLanguage),
                initialValue: currentPreferences.preferredLanguage,
                decoration: InputDecoration(
                  labelText: tr.settings.languageLabel,
                ),
                items: [
                  DropdownMenuItem(
                    value: PreferredLanguage.en,
                    child: Text(tr.settings.languageEnglish),
                  ),
                  DropdownMenuItem(
                    value: PreferredLanguage.esCo,
                    child: Text(tr.settings.languageSpanishColombia),
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
                              .setPreferredLanguage(value),
                        );
                      },
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<NotificationMethod>(
                key: ValueKey(currentPreferences.preferredNotificationMethod),
                initialValue: currentPreferences.preferredNotificationMethod,
                decoration: InputDecoration(
                  labelText: tr.settings.defaultNotificationMethodLabel,
                ),
                items: [
                  DropdownMenuItem(
                    value: NotificationMethod.email,
                    child: Text(tr.settings.notificationEmail),
                  ),
                  DropdownMenuItem(
                    value: NotificationMethod.sms,
                    child: Text(tr.settings.notificationSms),
                  ),
                  DropdownMenuItem(
                    value: NotificationMethod.none,
                    child: Text(tr.settings.notificationAskEachTime),
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
                title: Text(tr.settings.requireCancellationConfirmationTitle),
                subtitle: Text(
                  tr.settings.requireCancellationConfirmationSubtitle,
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
          title: tr.settings.dangerZoneTitle,
          description: tr.settings.dangerZoneDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _DangerZoneHintBanner(),
              const SizedBox(height: AppSpacing.md),
              _DangerActionTile(
                icon: Icons.restart_alt,
                title: tr.settings.resetPortfolioTitle,
                subtitle: tr.settings.resetPortfolioSubtitle,
                isBusy: maintenanceState.isResettingPortfolio,
                focusOrder: 1,
                actionLabel: tr.settings.resetPortfolioAction,
                onPressed: () => _confirmAndResetPortfolio(context, ref),
              ),
              const SizedBox(height: AppSpacing.md),
              _DangerActionTile(
                icon: Icons.tune,
                title: tr.settings.resetPreferencesTitle,
                subtitle: tr.settings.resetPreferencesSubtitle,
                isBusy: maintenanceState.isResettingPreferences,
                focusOrder: 2,
                actionLabel: tr.settings.resetPreferencesAction,
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
    final tr = context.t;
    final confirmed = await _showDangerConfirmationDialog(
      context,
      title: tr.settings.resetPortfolioConfirmTitle,
      message: tr.settings.resetPortfolioConfirmMessage,
      actionLabel: tr.settings.resetPortfolioAction,
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
        SnackBar(content: Text(tr.settings.resetPortfolioSuccess)),
      );
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text(tr.settings.resetFailed(error: '$error'))),
      );
    }
  }

  Future<void> _confirmAndResetPreferences(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final tr = context.t;
    final confirmed = await _showDangerConfirmationDialog(
      context,
      title: tr.settings.resetPreferencesConfirmTitle,
      message: tr.settings.resetPreferencesConfirmMessage,
      actionLabel: tr.settings.resetPreferencesAction,
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
        SnackBar(content: Text(tr.settings.resetPreferencesSuccess)),
      );
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text(tr.settings.resetFailed(error: '$error'))),
      );
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
              context.t.settings.cannotUndo,
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
            label: context.t.settings.keepDataSemantics,
            child: TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.t.settings.keepData),
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
              context.t.settings.dangerZoneHint,
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
