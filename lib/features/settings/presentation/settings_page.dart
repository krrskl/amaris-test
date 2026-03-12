import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Card(
          child: ListTile(
            title: Text('Notifications'),
            subtitle: Text(
              'Email/SMS preferences will be wired in next slice.',
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          child: ListTile(
            title: Text('Persistence'),
            subtitle: Text(
              'hive_ce integration planned in persistence increment.',
            ),
          ),
        ),
      ],
    );
  }
}
