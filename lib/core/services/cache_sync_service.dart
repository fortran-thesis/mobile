import 'dart:async';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/utils/cache_invalidation.dart';
import 'package:moldify/core/utils/logger.dart';

/// Service that subscribes to cache invalidation events and flushes the cache.
///
/// When a mutation occurs (create, update, delete), this service immediately
/// clears the relevant cached entries so subsequent requests fetch fresh data
/// from the server.
class CacheSyncService {
  CacheSyncService._();
  static final CacheSyncService instance = CacheSyncService._();

  late final StreamSubscription<CacheInvalidationEvent> _subscription;
  bool _initialized = false;

  /// Initialize the cache sync service.
  /// Must be called once during app startup.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _subscription = CacheInvalidationHub.instance.stream.listen(
      _onCacheInvalidationEvent,
      onError: (error) {
        AppLogger.e('Cache sync error', error: error, tag: 'CacheSync');
      },
    );

    AppLogger.d('Cache sync service initialized', tag: 'CacheSync');
  }

  /// Handle a cache invalidation event by flushing the cache store.
  Future<void> _onCacheInvalidationEvent(CacheInvalidationEvent event) async {
    AppLogger.d(
      'Cache invalidation event: ${event.entity} ${event.operation} (id: ${event.id})',
      tag: 'CacheSync',
    );

    // Clear the entire in-memory cache to ensure fresh data on next request.
    // For a more granular approach, we could selectively clear entries based on:
    // - entity type (moldReport, moldCase, etc.)
    // - specific cache keys (e.g., /api/v1/reports/${id})
    // For now, we use the simpler clearAll approach for consistency and simplicity.
    await CacheConfig.clearAll();
    AppLogger.d(
      'Cache cleared for ${event.entity} ${event.operation}',
      tag: 'CacheSync',
    );
  }

  /// Dispose the service (cancel subscription).
  Future<void> dispose() async {
    if (!_initialized) return;
    await _subscription.cancel();
    _initialized = false;
    AppLogger.d('Cache sync service disposed', tag: 'CacheSync');
  }
}
