import 'package:amaris_test/core/ui/breakpoints/app_breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBreakpoints.fromWidth', () {
    test('returns compact when width is below 600', () {
      expect(AppBreakpoints.fromWidth(320), AppWindowSize.compact);
      expect(AppBreakpoints.fromWidth(599.9), AppWindowSize.compact);
    });

    test('returns medium when width is from 600 to 1023.9', () {
      expect(AppBreakpoints.fromWidth(600), AppWindowSize.medium);
      expect(AppBreakpoints.fromWidth(800), AppWindowSize.medium);
      expect(AppBreakpoints.fromWidth(1023.9), AppWindowSize.medium);
    });

    test('returns expanded when width is 1024 or more', () {
      expect(AppBreakpoints.fromWidth(1024), AppWindowSize.expanded);
      expect(AppBreakpoints.fromWidth(1440), AppWindowSize.expanded);
    });
  });
}
