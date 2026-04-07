import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/settings/case_history.dart';

void main() {
  group('resolveCaseHistoryRouteForRole', () {
    test('returns report view for farmer and user roles', () {
      expect(resolveCaseHistoryRouteForRole('farmer'), RouteNames.viewReport);
      expect(resolveCaseHistoryRouteForRole('user'), RouteNames.viewReport);
    });

    test('returns case view for mycologist, curator, and admin', () {
      expect(resolveCaseHistoryRouteForRole('mycologist'), RouteNames.viewCase);
      expect(resolveCaseHistoryRouteForRole('curator'), RouteNames.viewCase);
      expect(resolveCaseHistoryRouteForRole('admin'), RouteNames.viewCase);
    });

    test('falls back to report view for null, empty, and unknown roles', () {
      expect(resolveCaseHistoryRouteForRole(null), RouteNames.viewReport);
      expect(resolveCaseHistoryRouteForRole(''), RouteNames.viewReport);
      expect(
        resolveCaseHistoryRouteForRole('unknown-role'),
        RouteNames.viewReport,
      );
    });

    test('normalizes whitespace and case', () {
      expect(
        resolveCaseHistoryRouteForRole('  MYCOLOGIST  '),
        RouteNames.viewCase,
      );
      expect(resolveCaseHistoryRouteForRole('  USER  '), RouteNames.viewReport);
    });
  });
}
