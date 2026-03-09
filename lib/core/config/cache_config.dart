import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Centralised cache configuration for Dio HTTP responses.
///
/// Provides a shared [MemCacheStore] and pre-built [CachePolicy] presets
/// that services inject via `options.extra` on each request.
///
/// Cache tiers:
///  - **static**  — reference data that rarely changes (moldipedia, FAQ, mold
///    taxonomy).  Cache-first with a 24-hour max-stale window.
///  - **volatile** — user-generated / real-time data (reports, cases, counts).
///    Network-first with a 5-minute stale fallback for offline/slow networks.
///  - **noCache** — mutations (POST / PATCH / DELETE) and auth calls.
class CacheConfig {
  CacheConfig._();

  // ── Shared in-memory store ─────────────────────────────────────────────
  /// Single [MemCacheStore] instance shared across all [ApiService] clients.
  /// Survives for the lifetime of the app process; cleared on restart.
  static final CacheStore store = MemCacheStore();

  // ── TTL constants ──────────────────────────────────────────────────────
  static const Duration staticMaxAge = Duration(hours: 24);
  static const Duration staticMaxStale = Duration(days: 7);
  static const Duration volatileMaxAge = Duration(minutes: 5);
  static const Duration volatileMaxStale = Duration(minutes: 15);

  // ── Default options (applied globally by the interceptor) ──────────────
  static final CacheOptions defaultOptions = CacheOptions(
    store: store,
    policy: CachePolicy.refreshForceCache, // network-first, fallback to cache
    maxStale: volatileMaxStale,
    hitCacheOnErrorExcept: [401, 403], // serve stale on server errors
  );

  // ── Per-request policy presets ─────────────────────────────────────────

  /// For **static / reference** data: serve from cache unless expired,
  /// only hit network when stale window passes.
  static CacheOptions get staticData => defaultOptions.copyWith(
        policy: CachePolicy.forceCache,
        maxStale: const Nullable(staticMaxStale),
      );

  /// For **volatile / user** data: always try network first but fall back
  /// to cached response when offline or on error.
  static CacheOptions get volatileData => defaultOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
        maxStale: const Nullable(volatileMaxStale),
      );

  /// Force a fresh network call and update the cache with the result.
  /// Use after a mutation (create / update / delete) when the caller
  /// immediately re-fetches the updated list.
  static CacheOptions get refresh => defaultOptions.copyWith(
        policy: CachePolicy.refresh,
      );

  /// Skip cache entirely — for writes and auth endpoints.
  static CacheOptions get noCache => defaultOptions.copyWith(
        policy: CachePolicy.noCache,
      );

  // ── Utility ────────────────────────────────────────────────────────────

  /// Evict all cached responses (e.g. on logout).
  static Future<void> clearAll() => store.clean();
}
