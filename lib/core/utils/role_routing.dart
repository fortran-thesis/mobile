import 'package:moldify/core/constants/route_names.dart';

const Set<String> _caseViewRoles = {'mycologist', 'curator', 'admin'};

String normalizeUserRole(String? role) {
  return role?.trim().toLowerCase() ?? '';
}

bool isCaseViewRole(String? role) {
  return _caseViewRoles.contains(normalizeUserRole(role));
}

String resolveCaseHistoryRouteForRole(String? role) {
  return isCaseViewRole(role) ? RouteNames.viewCase : RouteNames.viewReport;
}
