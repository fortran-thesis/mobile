import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

/// Service layer for the notification API endpoints.
///
/// Follows the same pattern as [MoldCaseService]:
///   • One [ApiService] instance per feature
///   • Each method returns the raw response map
///   • Status checking left to the caller / repository
class NotificationService {
  final ApiService _apiService = ApiService(baseUrl: ApiUrl.notification);

  /// Fetch paginated notifications for the current user.
  /// Endpoint: GET /
  Future<Map<String, dynamic>> fetchNotifications({
    String? sessionCookie,
    int? limit,
    String? pageToken,
    bool? isRead,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (pageToken != null) queryParams['pageToken'] = pageToken;
    if (isRead != null) queryParams['is_read'] = isRead;
    if (type != null) queryParams['type'] = type;

    final response = await _apiService.get(
      '',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      queryParams: queryParams.isEmpty ? null : queryParams,
      cacheOptions: CacheConfig.volatileData,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch notifications: ${response.statusCode}');
  }

  /// Fetch the unread notification count.
  /// Endpoint: GET /unread-count
  Future<Map<String, dynamic>> fetchUnreadCount({
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/unread-count',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.noCache,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch unread count: ${response.statusCode}');
  }

  /// Get a single notification by ID.
  /// Endpoint: GET /:id
  Future<Map<String, dynamic>> getNotificationById(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.get(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
      cacheOptions: CacheConfig.noCache,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch notification $id: ${response.statusCode}');
  }

  /// Mark a single notification as read.
  /// Endpoint: PATCH /:id/read
  Future<void> markAsRead(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.patch(
      '/$id/read',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification $id as read: ${response.statusCode}');
    }
  }

  /// Mark all notifications as read.
  /// Endpoint: PATCH /read-all
  Future<void> markAllAsRead({
    String? sessionCookie,
  }) async {
    final response = await _apiService.patch(
      '/read-all',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
    }
  }

  /// Delete (soft-delete) a notification.
  /// Endpoint: DELETE /:id
  Future<void> deleteNotification(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.delete(
      '/$id',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification $id: ${response.statusCode}');
    }
  }

  /// Register a device token for push notifications.
  /// Endpoint: POST /device-token
  Future<Map<String, dynamic>> registerDeviceToken({
    required String token,
    required String platform,
    String? sessionCookie,
  }) async {
    final response = await _apiService.post(
      '/device-token',
      headers: {'Content-Type': 'application/json'},
      body: {'token': token, 'platform': platform},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Failed to register device token: ${response.statusCode}');
  }

  /// Remove a device token.
  /// Endpoint: DELETE /device-token/:id
  Future<void> removeDeviceToken(
    String id, {
    String? sessionCookie,
  }) async {
    final response = await _apiService.delete(
      '/device-token/$id',
      headers: {'Content-Type': 'application/json'},
      sessionCookie: sessionCookie,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove device token $id: ${response.statusCode}');
    }
  }
}
