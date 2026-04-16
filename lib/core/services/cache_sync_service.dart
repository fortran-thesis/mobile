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

  /// Handle a cache invalidation event.
  ///
  /// Only [InvalidationEntity.authSession] events flush the entire store —
  /// that covers logout and session switches where stale data from the
  /// previous user must not survive.
  ///
  /// For all other entities (moldReport, moldCase, etc.) the cache does NOT
  /// need to be cleared: every hot read path uses [CachePolicy.refreshForceCache]
  /// (volatile), which always goes to the network first and only falls back to
  /// the cached copy on errors. Clearing the store on every mutation would
  /// evict unrelated entries and cause unnecessary network round-trips.
  Future<void> _onCacheInvalidationEvent(CacheInvalidationEvent event) async {
    AppLogger.d(
      'Cache invalidation event: ${event.entity} ${event.operation} (id: ${event.id})',
      tag: 'CacheSync',
    );

    if (event.entity == InvalidationEntity.authSession) {
      await CacheConfig.clearAll();
      AppLogger.d('Cache fully cleared on authSession invalidation', tag: 'CacheSync');
    }
    // For moldReport / moldCase / etc. the volatile cache policy already
    // ensures the next fetch hits the network — no explicit eviction needed.
  }

  /// Dispose the service (cancel subscription).
  Future<void> dispose() async {
    if (!_initialized) return;
    await _subscription.cancel();
    _initialized = false;
    AppLogger.d('Cache sync service disposed', tag: 'CacheSync');
  }
}
