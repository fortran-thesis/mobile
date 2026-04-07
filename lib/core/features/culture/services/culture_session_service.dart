import 'package:moldify/core/features/mold_case/service/mold_case_service.dart';
import 'package:moldify/core/utils/logger.dart';

class CultureSession {
  final String id;
  final String caseId;
  final String name;
  final DateTime createdAt;
  final DateTime targetAt;
  final DateTime? endedAt;
  final String? status;
  final bool? isAvailableForLogsFromApi;

  CultureSession({
    required this.id,
    required this.caseId,
    required this.name,
    required this.createdAt,
    required this.targetAt,
    this.endedAt,
    this.status,
    this.isAvailableForLogsFromApi,
  });

  factory CultureSession.fromJson(Map<String, dynamic> json) {
    final metadata = (json['metadata'] is Map<String, dynamic>)
        ? json['metadata'] as Map<String, dynamic>
        : null;

    final created = _parseDateTime(
      json['created_at'] ?? metadata?['created_at'],
    );

    return CultureSession(
      id: json['id']?.toString().trim() ?? '',
      caseId: (json['case_id'] ?? json['caseId'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      createdAt: created ?? DateTime.now().toUtc(),
      targetAt: _parseDateTime(json['target_at'] ?? json['targetDate']) ??
          DateTime.now().toUtc(),
      endedAt: _parseDateTime(json['ended_at'] ?? json['endedAt']),
      status: json['status']?.toString(),
      isAvailableForLogsFromApi: json['is_available_for_logs'] is bool
          ? json['is_available_for_logs'] as bool
          : null,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    if (value is Map) {
      final seconds = value['_seconds'] ?? value['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
      }
    }
    return null;
  }

  bool get isEndedEarly => endedAt != null || status == 'ended_early';

  bool get isTimerElapsed {
    final now = DateTime.now().toUtc();
    return now.isAfter(targetAt.toUtc()) || now.isAtSameMomentAs(targetAt.toUtc());
  }

  bool get isAvailableForLogs {
    if (isAvailableForLogsFromApi != null) return isAvailableForLogsFromApi!;
    return !isEndedEarly && isTimerElapsed;
  }

  String get availabilityLabel {
    final normalized = (status ?? '').trim().toLowerCase();
    if (normalized == 'ended_early' || isEndedEarly) return 'Ended early';
    if (normalized == 'available' || isAvailableForLogs) return 'Available';
    return 'Incubating';
  }

  CultureSession copyWith({
    DateTime? targetAt,
    DateTime? endedAt,
    String? status,
    bool? isAvailableForLogsFromApi,
  }) {
    return CultureSession(
      id: id,
      caseId: caseId,
      name: name,
      createdAt: createdAt,
      targetAt: targetAt ?? this.targetAt,
      endedAt: endedAt,
      status: status ?? this.status,
      isAvailableForLogsFromApi:
          isAvailableForLogsFromApi ?? this.isAvailableForLogsFromApi,
    );
  }
}

class CultureSessionService {
  CultureSessionService._();

  static final CultureSessionService instance = CultureSessionService._();

  final MoldCaseService _moldCaseService = MoldCaseService();
  final List<CultureSession> _fallbackSessions = [];

  List<CultureSession> _fallbackForCase(String caseId) {
    final normalizedCaseId = caseId.trim();
    final filtered = _fallbackSessions
        .where((session) => session.caseId == normalizedCaseId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  void _replaceFallbackForCase(String caseId, List<CultureSession> sessions) {
    final normalizedCaseId = caseId.trim();
    _fallbackSessions.removeWhere((item) => item.caseId == normalizedCaseId);
    _fallbackSessions.addAll(sessions);
  }

  void _upsertFallback(CultureSession session) {
    final index = _fallbackSessions.indexWhere((item) => item.id == session.id);
    if (index == -1) {
      _fallbackSessions.add(session);
    } else {
      _fallbackSessions[index] = session;
    }
  }

  Future<List<CultureSession>> getAll({
    required String caseId,
    String? sessionCookie,
  }) async {
    final normalizedCaseId = caseId.trim();
    if (normalizedCaseId.isEmpty) return const [];

    try {
      final payload = await _moldCaseService.listCultureSessions(
        normalizedCaseId,
        sessionCookie: sessionCookie,
      );

      final snapshot = payload['snapshot'];
      if (snapshot is! List) return _fallbackForCase(normalizedCaseId);

      final sessions = snapshot
          .whereType<Map>()
          .map((raw) => CultureSession.fromJson(Map<String, dynamic>.from(raw)))
          .where((item) => item.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _replaceFallbackForCase(normalizedCaseId, sessions);
      return sessions;
    } catch (e) {
      AppLogger.e('CultureSessionService: falling back to local session cache', error: e);
      return _fallbackForCase(normalizedCaseId);
    }
  }

  Future<List<CultureSession>> getAvailableForLogs(
    String caseId, {
    String? sessionCookie,
  }) async {
    final normalizedCaseId = caseId.trim();
    if (normalizedCaseId.isEmpty) return const [];

    try {
      final payload = await _moldCaseService.listAvailableCultureSessions(
        normalizedCaseId,
        sessionCookie: sessionCookie,
      );

      final sessions = payload
          .map(CultureSession.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (sessions.isNotEmpty) {
        for (final session in sessions) {
          _upsertFallback(session);
        }
      }

      return sessions;
    } catch (e) {
      AppLogger.e('CultureSessionService: available endpoint failed, using fallback', error: e);
      return _fallbackForCase(normalizedCaseId)
          .where((session) => session.isAvailableForLogs)
          .toList();
    }
  }

  Future<CultureSession?> createCulture({
    required String caseId,
    required String name,
    required DateTime targetAt,
    String? sessionCookie,
  }) async {
    final normalizedCaseId = caseId.trim();
    final normalizedName = name.trim();
    if (normalizedCaseId.isEmpty || normalizedName.isEmpty) return null;

    try {
      final created = await _moldCaseService.createCultureSession(
        normalizedCaseId,
        name: normalizedName,
        targetAt: targetAt,
        sessionCookie: sessionCookie,
      );

      final session = CultureSession.fromJson(created);
      _upsertFallback(session);
      return session;
    } catch (e) {
      AppLogger.e('CultureSessionService: create failed, creating fallback session', error: e);

      final now = DateTime.now().toUtc();
      final fallback = CultureSession(
        id: 'fallback_${now.microsecondsSinceEpoch}',
        caseId: normalizedCaseId,
        name: normalizedName,
        createdAt: now,
        targetAt: targetAt.toUtc(),
      );
      _upsertFallback(fallback);
      return fallback;
    }
  }

  Future<bool> endEarly(
    String cultureId, {
    required String caseId,
    String? sessionCookie,
  }) async {
    final normalizedCaseId = caseId.trim();
    final normalizedCultureId = cultureId.trim();
    if (normalizedCaseId.isEmpty || normalizedCultureId.isEmpty) return false;

    try {
      final updated = await _moldCaseService.endCultureSessionEarly(
        normalizedCaseId,
        normalizedCultureId,
        sessionCookie: sessionCookie,
      );
      _upsertFallback(CultureSession.fromJson(updated));
      return true;
    } catch (e) {
      AppLogger.e('CultureSessionService: end-early failed, using fallback cache', error: e);
      final index = _fallbackSessions.indexWhere((item) => item.id == normalizedCultureId);
      if (index == -1) return false;
      _fallbackSessions[index] = _fallbackSessions[index].copyWith(
        endedAt: DateTime.now().toUtc(),
        status: 'ended_early',
        isAvailableForLogsFromApi: false,
      );
      return true;
    }
  }

  Future<bool> reassignTimer(
    String cultureId,
    DateTime newTargetAt, {
    required String caseId,
    String? sessionCookie,
  }) async {
    final normalizedCaseId = caseId.trim();
    final normalizedCultureId = cultureId.trim();
    if (normalizedCaseId.isEmpty || normalizedCultureId.isEmpty) return false;

    try {
      final updated = await _moldCaseService.reassignCultureSession(
        normalizedCaseId,
        normalizedCultureId,
        targetAt: newTargetAt,
        sessionCookie: sessionCookie,
      );
      _upsertFallback(CultureSession.fromJson(updated));
      return true;
    } catch (e) {
      AppLogger.e('CultureSessionService: reassign failed, using fallback cache', error: e);
      final index = _fallbackSessions.indexWhere((item) => item.id == normalizedCultureId);
      if (index == -1) return false;
      _fallbackSessions[index] = _fallbackSessions[index].copyWith(
        targetAt: newTargetAt.toUtc(),
        endedAt: null,
        status: 'incubating',
        isAvailableForLogsFromApi: false,
      );
      return true;
    }
  }

  Future<bool> deleteCulture(
    String cultureId, {
    required String caseId,
    String? sessionCookie,
  }) async {
    final normalizedCaseId = caseId.trim();
    final normalizedCultureId = cultureId.trim();
    if (normalizedCaseId.isEmpty || normalizedCultureId.isEmpty) return false;

    try {
      await _moldCaseService.deleteCultureSession(
        normalizedCaseId,
        normalizedCultureId,
        sessionCookie: sessionCookie,
      );
      _fallbackSessions.removeWhere((item) => item.id == normalizedCultureId);
      return true;
    } catch (e) {
      AppLogger.e('CultureSessionService: delete failed, using fallback cache', error: e);
      final before = _fallbackSessions.length;
      _fallbackSessions.removeWhere((item) => item.id == normalizedCultureId);
      return _fallbackSessions.length != before;
    }
  }
}
