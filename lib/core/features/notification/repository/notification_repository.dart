import 'package:moldify/core/features/notification/models/notification.dart';
import 'package:moldify/core/features/notification/service/notification_service.dart';
import 'package:moldify/core/utils/logger.dart';

/// Repository layer for notifications, mapping raw API responses to [AppNotification] models.
///
/// Follows the same normalization pattern as [MoldCaseRepository].
class NotificationRepository {
  final NotificationService _service = NotificationService();
  final int pageSize;

  NotificationRepository({this.pageSize = 20});

  /// Fetch a page of notifications from the API.
  Future<List<AppNotification>> fetchPage({
    String? pageToken,
    String? sessionCookie,
    bool? isRead,
    String? type,
  }) async {
    AppLogger.d(
      'NotificationRepository: fetching page (pageToken: "$pageToken", limit: $pageSize)',
    );
    final result = await _service.fetchNotifications(
      sessionCookie: sessionCookie,
      limit: pageSize,
      pageToken: pageToken,
      isRead: isRead,
      type: type,
    );
    AppLogger.d('NotificationRepository: raw API response: $result');

    // Normalize shape — backend returns:
    //   { success: true, data: { snapshot: [...], nextPageToken: ... } }
    dynamic raw = result;
    if (result.containsKey('data')) raw = result['data'];

    List<dynamic> rawList = <dynamic>[];
    if (raw is List) {
      rawList = raw;
    } else if (raw is Map) {
      if (raw['snapshot'] is List) {
        rawList = raw['snapshot'] as List<dynamic>;
      } else if (raw['data'] is List) {
        rawList = raw['data'] as List<dynamic>;
      }
    }

    AppLogger.d('NotificationRepository: normalized rawList (${rawList.length} items)');

    final notifications = rawList
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .where((n) => n.id.isNotEmpty)
        .toList();

    AppLogger.d('NotificationRepository: parsed ${notifications.length} notifications');
    return notifications;
  }

  /// Fetch a single notification by ID.
  Future<AppNotification?> getById(String id, {String? sessionCookie}) async {
    final data = await _service.getNotificationById(id, sessionCookie: sessionCookie);
    final payload = (data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : data;
    return AppNotification.fromJson(payload);
  }

  /// Get the unread notification count.
  Future<int> fetchUnreadCount({String? sessionCookie}) async {
    final data = await _service.fetchUnreadCount(sessionCookie: sessionCookie);
    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      return (payload['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String id, {String? sessionCookie}) async {
    await _service.markAsRead(id, sessionCookie: sessionCookie);
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead({String? sessionCookie}) async {
    await _service.markAllAsRead(sessionCookie: sessionCookie);
  }

  /// Delete a notification.
  Future<void> deleteNotification(String id, {String? sessionCookie}) async {
    await _service.deleteNotification(id, sessionCookie: sessionCookie);
  }
}
