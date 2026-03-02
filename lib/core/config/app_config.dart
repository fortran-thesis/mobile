/// App Configuration
/// All values are injected at build / run time via --dart-define-from-file.
///
/// Development:  flutter run  --dart-define-from-file=env.dev.json
/// Production:   flutter build apk --dart-define-from-file=env.prod.json --release
///
/// Copy env.example.json → env.dev.json and fill in your own values.
/// env.dev.json and env.prod.json are git-ignored; env.example.json is committed.
class AppConfig {
  // ── Environment name ───────────────────────────────────────────────────────
  /// Either "dev" or "prod" — set in the json file as the "ENV" key.
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDev => env == 'dev';
  static bool get isProd => env == 'prod';

  // ── API base URL (no trailing slash, no /api/v1 suffix) ───────────────────
  /// Example dev value : http://192.168.100.45:5001/thesis-2e701/asia-southeast1
  /// Example prod value: https://api.moldify.app
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5001/thesis-2e701/asia-southeast1',
  );

  // ── ML model base URL ─────────────────────────────────────────────────────
  static const String modelBaseUrl = String.fromEnvironment(
    'MODEL_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  // ── Feature flags ─────────────────────────────────────────────────────────
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );

  // ── Firebase ──────────────────────────────────────────────────────────────
  static const String firebaseProjectId = 'thesis-2e701';

  // ── Convenience getters ───────────────────────────────────────────────────
  /// Full API prefix used by every endpoint, e.g. "<base>/api/v1".
  static String get apiV1 => '$apiBaseUrl/api/v1';

  static void logConfig() {
    // ignore: avoid_print
    print('🔧 [AppConfig] ENV=$env | apiBaseUrl=$apiBaseUrl | modelBaseUrl=$modelBaseUrl | debugMode=$debugMode');
  }
}
