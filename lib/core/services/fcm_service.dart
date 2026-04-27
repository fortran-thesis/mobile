import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:moldify/core/features/notification/service/notification_service.dart';
import 'package:moldify/core/utils/logger.dart';

/// Top-level handler for background/terminated messages.
///
/// Must be a **top-level function** (not a class method) so the Flutter
/// engine can invoke it in a dedicated isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.d('Background message received: ${message.messageId}', tag: 'FCM');
}

/// Notification tap event data for deep linking
class NotificationTapEvent {
  final String referenceType;
  final String referenceId;

  NotificationTapEvent({
    required this.referenceType,
    required this.referenceId,
  });
}

/// Singleton service that manages the full FCM lifecycle:
///   1. Request notification permission
///   2. Obtain the device FCM token
///   3. Register / refresh the token with the backend
///   4. Listen for token-refresh events
///   5. Surface foreground messages via a callback
///   6. Emit notification tap events for deep linking
class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  final _notificationTapController =
      StreamController<NotificationTapEvent>.broadcast();
  NotificationTapEvent? _pendingTapEvent;

  String? _currentToken;
  String? _sessionCookie;
  String? get currentToken => _currentToken;
  Stream<NotificationTapEvent> get notificationTaps =>
      _notificationTapController.stream;

  NotificationTapEvent? consumePendingNotificationTap() {
    final pending = _pendingTapEvent;
    _pendingTapEvent = null;
    return pending;
  }

  /// Initialise FCM — call once after [Firebase.initializeApp].
  ///
  /// * Registers the background handler.
  /// * Requests permission on iOS / Android 13+.
  /// * Fetches the FCM token and registers it with the API.
  /// * Subscribes to token-refresh events.
  Future<void> initialise({
    String? sessionCookie,
    void Function(RemoteMessage)? onForegroundMessage,
  }) async {
    _sessionCookie = sessionCookie;

    // Background / terminated handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (no-op on older Android; prompts on iOS & Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      AppLogger.w('Notification permission denied', tag: 'FCM');
      return;
    }

    AppLogger.d(
      'Notification permission: ${settings.authorizationStatus}',
      tag: 'FCM',
    );

    // Obtain the token
    await _fetchAndRegisterToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.d('FCM token refreshed', tag: 'FCM');
      _currentToken = newToken;
      if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
        _registerToken(newToken, sessionCookie: _sessionCookie);
      } else {
        AppLogger.d(
          'FCM token refreshed before an authenticated session was available; caching only',
          tag: 'FCM',
        );
      }
    });

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.d(
        'Foreground message: ${message.notification?.title}',
        tag: 'FCM',
      );
      onForegroundMessage?.call(message);
    });

    // Handle notification taps (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.d('Notification tap (background): ${message.data}', tag: 'FCM');
      _handleNotificationTap(message);
    });

    // Check if the app was opened from a terminated state via a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.d(
        'App opened from terminated via notification: ${initialMessage.data}',
        tag: 'FCM',
      );
      _handleNotificationTap(initialMessage);
    }
  }

  /// Update the authenticated session cookie used for backend registration.
  ///
  /// When the cookie becomes available after app start or login, the cached FCM
  /// token is registered immediately.
  Future<void> updateSessionCookie(String? sessionCookie) async {
    _sessionCookie = sessionCookie;

    if (sessionCookie == null || sessionCookie.isEmpty) {
      return;
    }

    final token = _currentToken ?? await _messaging.getToken();
    if (token == null) {
      return;
    }

    _currentToken = token;
    await _registerToken(token, sessionCookie: sessionCookie);
  }

  /// Get the current FCM token and register with backend.
  Future<void> _fetchAndRegisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
          await _registerToken(token, sessionCookie: _sessionCookie);
        } else {
          AppLogger.d(
            'FCM token cached; waiting for an authenticated session before registering',
            tag: 'FCM',
          );
        }
      }
    } catch (e) {
      AppLogger.e('Failed to get FCM token', tag: 'FCM', error: e);
    }
  }

  /// Register a token with the backend API.
  Future<void> _registerToken(String token, {String? sessionCookie}) async {
    try {
      _currentToken = token;
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _notificationService.registerDeviceToken(
        token: token,
        platform: platform,
        sessionCookie: sessionCookie,
      );
      AppLogger.d('Device token registered ($platform)', tag: 'FCM');
    } catch (e) {
      AppLogger.e('Failed to register device token', tag: 'FCM', error: e);
    }
  }

  /// Remove the current device token from the backend (e.g. on logout).
  Future<void> removeCurrentToken({String? sessionCookie}) async {
    // The backend uses a token document ID — but we can also
    // delete the messaging token locally.
    try {
      await _messaging.deleteToken();
      _currentToken = null;
      AppLogger.d('FCM token deleted locally', tag: 'FCM');
    } catch (e) {
      AppLogger.e('Failed to delete FCM token', tag: 'FCM', error: e);
    }
  }

  /// Handle notification tap by emitting an event for app-level routing.
  void _handleNotificationTap(RemoteMessage message) {
    final referenceType = message.data['reference_type'];
    final referenceId = message.data['reference_id'];

    if (referenceType != null && referenceId != null) {
      final event = NotificationTapEvent(
        referenceType: referenceType,
        referenceId: referenceId,
      );
      if (!_notificationTapController.hasListener) {
        _pendingTapEvent = event;
      }
      AppLogger.d(
        'Emitting notification tap event: type=$referenceType, id=$referenceId',
        tag: 'FCM',
      );
      _notificationTapController.add(event);
    }
  }
}
