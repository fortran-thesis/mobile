import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/utils/notification_navigation.dart';

void main() {
  group('resolveNotificationNavigationTarget', () {
    test('routes mold_report to report for farmer and unknown roles', () {
      final farmerTarget = resolveNotificationNavigationTarget(
        referenceType: 'mold_report',
        referenceId: 'rep-1',
        userRole: 'farmer',
      );
      final unknownTarget = resolveNotificationNavigationTarget(
        referenceType: 'mold_report',
        referenceId: 'rep-1',
        userRole: null,
      );

      expect(farmerTarget?.routeName, RouteNames.viewReport);
      expect(unknownTarget?.routeName, RouteNames.viewReport);
      expect(farmerTarget?.arguments?['id'], 'rep-1');
    });

    test('routes mold_report to case for mycologist roles', () {
      final target = resolveNotificationNavigationTarget(
        referenceType: 'mold_report',
        referenceId: 'rep-2',
        userRole: 'mycologist',
      );

      expect(target?.routeName, RouteNames.viewCase);
      expect(target?.arguments?['id'], 'rep-2');
    });

    test('blocks mold_case for farmer role', () {
      final target = resolveNotificationNavigationTarget(
        referenceType: 'mold_case',
        referenceId: 'case-1',
        userRole: 'farmer',
      );

      expect(target, isNull);
    });

    test('routes mold_case for expert roles', () {
      final target = resolveNotificationNavigationTarget(
        referenceType: 'mold_case',
        referenceId: 'case-2',
        userRole: 'curator',
      );

      expect(target?.routeName, RouteNames.viewCase);
      expect(target?.arguments?['id'], 'case-2');
    });
  });
}
