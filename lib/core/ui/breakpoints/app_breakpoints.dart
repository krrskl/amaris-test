import 'package:flutter/widgets.dart';

enum AppWindowSize { compact, medium, expanded }

abstract final class AppBreakpoints {
  static const compactMaxWidth = 600.0;
  static const mediumMaxWidth = 1024.0;

  static AppWindowSize fromWidth(double width) {
    if (width < compactMaxWidth) {
      return AppWindowSize.compact;
    }
    if (width < mediumMaxWidth) {
      return AppWindowSize.medium;
    }
    return AppWindowSize.expanded;
  }

  static AppWindowSize fromContext(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }

  static bool isCompact(BuildContext context) {
    return fromContext(context) == AppWindowSize.compact;
  }

  static bool isMedium(BuildContext context) {
    return fromContext(context) == AppWindowSize.medium;
  }

  static bool isExpanded(BuildContext context) {
    return fromContext(context) == AppWindowSize.expanded;
  }
}
