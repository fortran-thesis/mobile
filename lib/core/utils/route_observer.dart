import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moldify/core/utils/logger.dart';

/// Stream-based route observer that emits events when screen navigation occurs.
///
/// Screens can mix in RouteAware and listen to this stream to detect
/// when they come back into focus (e.g., after a detail screen is popped).
/// Use this to refresh data when user navigates back.
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final _controller = StreamController<RouteEvent>.broadcast();

  Stream<RouteEvent> get routeEvents => _controller.stream;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.d(
      'didPop: ${route.settings.name} <- ${previousRoute?.settings.name}',
      tag: 'RouteObserver',
    );
    _controller.add(RouteEvent(
      type: RouteEventType.pop,
      route: route,
      previousRoute: previousRoute,
    ));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.d(
      'didPush: ${route.settings.name} -> ${previousRoute?.settings.name}',
      tag: 'RouteObserver',
    );
    _controller.add(RouteEvent(
      type: RouteEventType.push,
      route: route,
      previousRoute: previousRoute,
    ));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    AppLogger.d(
      'didRemove: ${route.settings.name}',
      tag: 'RouteObserver',
    );
    _controller.add(RouteEvent(
      type: RouteEventType.remove,
      route: route,
      previousRoute: previousRoute,
    ));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.d(
      'didReplace: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
      tag: 'RouteObserver',
    );
    _controller.add(RouteEvent(
      type: RouteEventType.replace,
      route: newRoute,
      previousRoute: oldRoute,
    ));
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

enum RouteEventType { push, pop, remove, replace }

class RouteEvent {
  final RouteEventType type;
  final Route<dynamic>? route;
  final Route<dynamic>? previousRoute;

  RouteEvent({
    required this.type,
    this.route,
    this.previousRoute,
  });

  String get routeName => route?.settings.name ?? 'unknown';
  String get previousRouteName => previousRoute?.settings.name ?? 'unknown';
}
