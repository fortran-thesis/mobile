import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/core/utils/role_routing.dart';

class NotificationNavigationTarget {
  final String routeName;
  final Map<String, dynamic>? arguments;

  const NotificationNavigationTarget({
    required this.routeName,
    this.arguments,
  });
}

NotificationNavigationTarget? resolveNotificationNavigationTarget({
  required String? referenceType,
  required String? referenceId,
  required String? userRole,
}) {
  final type = referenceType?.trim().toLowerCase();
  final id = referenceId?.trim();

  if (type == null || type.isEmpty || id == null || id.isEmpty) {
    return null;
  }

  switch (type) {
    case 'mold_report':
      return NotificationNavigationTarget(
        routeName: resolveCaseHistoryRouteForRole(userRole),
        arguments: {'id': id},
      );
    case 'mold_case':
      if (!isCaseViewRole(userRole)) {
        return null;
      }
      return NotificationNavigationTarget(
        routeName: RouteNames.viewCase,
        arguments: {'id': id},
      );
    case 'flag_report':
      return NotificationNavigationTarget(
        routeName: '/flag-report-detail',
        arguments: {'id': id},
      );
    case 'user':
      return NotificationNavigationTarget(
        routeName: '/user-profile',
        arguments: {'id': id},
      );
    default:
      return null;
  }
}
