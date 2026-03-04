import 'package:moldify/core/config/app_config.dart';

/// All endpoint constants derive from [AppConfig], which is populated
/// at build time via `--dart-define-from-file=env.<environment>.json`.
class ApiUrl {
  // Read from AppConfig — never hardcode here.
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// @deprecated The mobile app now routes model calls through the API proxy
  /// ([model]). MODEL_BASE_URL / modelUrl is no longer needed.
  @Deprecated('Use ApiUrl.model instead')
  static String get modelUrl => AppConfig.modelBaseUrl;

  /// @deprecated Use AppConfig.logConfig() instead.
  static void logConfig() => AppConfig.logConfig();

  // ── Endpoint roots ────────────────────────────────────────────────────────
  static String get _v1 => AppConfig.apiV1;

  static String get test => '$_v1/test';
  static String get auth => '$_v1/auth';
  static String get user => '$_v1/user';
  static String get moldReport => '$_v1/mold-report';
  static String get moldCase => '$_v1/mold-case';
  static String get moldipedia => '$_v1/moldipedia';
  static String get userReport => '$_v1/reports';
  static String get sysReq => '$_v1/system-request';
  static String get notification => '$_v1/notification';
  static String get model => '$_v1/model';
}
