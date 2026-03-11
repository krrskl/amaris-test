import 'package:amaris_test/core/ui/theme/app_spacing.dart';
import 'package:amaris_test/core/ui/theme/app_widths.dart';
import 'package:flutter/widgets.dart';

class ResponsivePageContainer extends StatelessWidget {
  const ResponsivePageContainer({
    required this.child,
    super.key,
    this.fullWidth = false,
  });

  final Widget child;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: fullWidth ? AppWidths.pageMax : AppWidths.contentMax,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
