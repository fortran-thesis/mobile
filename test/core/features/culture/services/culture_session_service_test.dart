import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/core/features/culture/services/culture_session_service.dart';

void main() {
  // ── CultureSession model ───────────────────────────────────────────────────

  group('CultureSession.fromJson', () {
    test('should parse fields from a complete JSON map', () {
      final now = DateTime.now().toUtc();
      final target = now.add(const Duration(hours: 24));
      final json = {
        'id': 'sess-1',
        'case_id': 'case-abc',
        'name': 'Batch Alpha',
        'target_at': target.toIso8601String(),
        'status': 'incubating',
        'is_available_for_logs': false,
        'metadata': {'created_at': now.toIso8601String()},
      };

      final session = CultureSession.fromJson(json);
      expect(session.id, equals('sess-1'));
      expect(session.caseId, equals('case-abc'));
      expect(session.name, equals('Batch Alpha'));
      expect(session.status, equals('incubating'));
      expect(session.isAvailableForLogsFromApi, isFalse);
      expect(session.endedAt, isNull);
    });

    test('should parse target_at from _seconds timestamp map', () {
      final target = DateTime(2025, 6, 1, 12, 0).toUtc();
      final seconds = target.millisecondsSinceEpoch ~/ 1000;
      final json = {
        'id': 'sess-2',
        'case_id': 'case-xyz',
        'name': 'Batch Beta',
        'target_at': {'_seconds': seconds, '_nanoseconds': 0},
        'metadata': {'created_at': DateTime.now().toIso8601String()},
      };

      final session = CultureSession.fromJson(json);
      expect(session.targetAt.millisecondsSinceEpoch ~/ 1000, equals(seconds));
    });

    test('should parse ended_at from ISO string', () {
      final endedAt = DateTime(2025, 5, 10).toUtc().toIso8601String();
      final json = {
        'id': 'sess-3',
        'case_id': 'case-xyz',
        'name': 'Batch Gamma',
        'target_at': DateTime.now().toIso8601String(),
        'ended_at': endedAt,
        'status': 'ended_early',
        'metadata': {'created_at': DateTime.now().toIso8601String()},
      };

      final session = CultureSession.fromJson(json);
      expect(session.endedAt, isNotNull);
      expect(session.endedAt!.year, equals(2025));
      expect(session.endedAt!.month, equals(5));
    });

    test('should handle missing ended_at as null', () {
      final json = {
        'id': 'sess-4',
        'case_id': 'case-xyz',
        'name': 'Batch Delta',
        'target_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'metadata': {'created_at': DateTime.now().toIso8601String()},
      };

      final session = CultureSession.fromJson(json);
      expect(session.endedAt, isNull);
    });

    test('should trim whitespace from id and name', () {
      final json = {
        'id': '  sess-5  ',
        'case_id': '  case-abc  ',
        'name': '  Batch Epsilon  ',
        'target_at': DateTime.now().toIso8601String(),
        'metadata': {'created_at': DateTime.now().toIso8601String()},
      };

      final session = CultureSession.fromJson(json);
      expect(session.id, equals('sess-5'));
      expect(session.caseId, equals('case-abc'));
      expect(session.name, equals('Batch Epsilon'));
    });
  });

  // ── Computed properties ────────────────────────────────────────────────────

  group('CultureSession.isEndedEarly', () {
    test('returns true when endedAt is set', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().subtract(const Duration(hours: 1)).toUtc(),
        endedAt: DateTime.now().toUtc(),
      );
      expect(session.isEndedEarly, isTrue);
    });

    test('returns true when status is ended_early even without endedAt', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().subtract(const Duration(hours: 1)).toUtc(),
        status: 'ended_early',
      );
      expect(session.isEndedEarly, isTrue);
    });

    test('returns false when endedAt is null and status is not ended_early', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().add(const Duration(hours: 1)).toUtc(),
      );
      expect(session.isEndedEarly, isFalse);
    });
  });

  group('CultureSession.isTimerElapsed', () {
    test('returns true when targetAt is in the past', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().subtract(const Duration(minutes: 1)).toUtc(),
      );
      expect(session.isTimerElapsed, isTrue);
    });

    test('returns false when targetAt is in the future', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().add(const Duration(hours: 2)).toUtc(),
      );
      expect(session.isTimerElapsed, isFalse);
    });
  });

  group('CultureSession.isAvailableForLogs', () {
    test('delegates to isAvailableForLogsFromApi when it is set', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().add(const Duration(hours: 1)).toUtc(), // future
        isAvailableForLogsFromApi: true, // API says available despite future target
      );
      expect(session.isAvailableForLogs, isTrue);
    });

    test('falls back to local timer logic when isAvailableForLogsFromApi is null', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().subtract(const Duration(minutes: 1)).toUtc(),
      );
      expect(session.isAvailableForLogs, isTrue);
    });

    test('returns false when not ended and timer has not elapsed', () {
      final session = CultureSession(
        id: 's',
        caseId: 'c',
        name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().add(const Duration(hours: 3)).toUtc(),
      );
      expect(session.isAvailableForLogs, isFalse);
    });
  });

  group('CultureSession.availabilityLabel', () {
    test('returns "Ended early" when status is ended_early', () {
      final session = CultureSession(
        id: 's', caseId: 'c', name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().subtract(const Duration(minutes: 1)).toUtc(),
        status: 'ended_early',
      );
      expect(session.availabilityLabel, equals('Ended early'));
    });

    test('returns "Ended early" when endedAt is set', () {
      final session = CultureSession(
        id: 's', caseId: 'c', name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().subtract(const Duration(minutes: 1)).toUtc(),
        endedAt: DateTime.now().toUtc(),
      );
      expect(session.availabilityLabel, equals('Ended early'));
    });

    test('returns "Available" when timer elapsed and not ended', () {
      final session = CultureSession(
        id: 's', caseId: 'c', name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().subtract(const Duration(minutes: 30)).toUtc(),
        status: 'available',
      );
      expect(session.availabilityLabel, equals('Available'));
    });

    test('returns "Incubating" when timer has not elapsed', () {
      final session = CultureSession(
        id: 's', caseId: 'c', name: 'N',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().add(const Duration(hours: 2)).toUtc(),
      );
      expect(session.availabilityLabel, equals('Incubating'));
    });
  });

  group('CultureSession.copyWith', () {
    test('should update targetAt and preserve other fields', () {
      final original = CultureSession(
        id: 's-1', caseId: 'c-1', name: 'Original',
        createdAt: DateTime(2024, 1, 1).toUtc(),
        targetAt: DateTime(2024, 6, 1).toUtc(),
        endedAt: DateTime(2024, 5, 1).toUtc(),
        status: 'ended_early',
      );
      final newTarget = DateTime(2024, 12, 31).toUtc();

      final copy = original.copyWith(targetAt: newTarget, endedAt: null);

      expect(copy.id, equals('s-1'));
      expect(copy.caseId, equals('c-1'));
      expect(copy.name, equals('Original'));
      expect(copy.targetAt, equals(newTarget));
      expect(copy.endedAt, isNull);
    });

    test('should update endedAt without affecting targetAt', () {
      final original = CultureSession(
        id: 's-2', caseId: 'c-2', name: 'Batch',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime(2024, 9, 1).toUtc(),
      );
      final ended = DateTime(2024, 8, 15).toUtc();

      final copy = original.copyWith(endedAt: ended, status: 'ended_early');

      expect(copy.endedAt, equals(ended));
      expect(copy.targetAt, equals(original.targetAt));
      expect(copy.status, equals('ended_early'));
    });

    test('should update isAvailableForLogsFromApi', () {
      final original = CultureSession(
        id: 's-3', caseId: 'c-3', name: 'Batch',
        createdAt: DateTime.now().toUtc(),
        targetAt: DateTime.now().add(const Duration(hours: 1)).toUtc(),
        isAvailableForLogsFromApi: false,
      );

      final copy = original.copyWith(isAvailableForLogsFromApi: true);

      expect(copy.isAvailableForLogsFromApi, isTrue);
    });
  });

  // ── CultureSessionService guard conditions ─────────────────────────────────
  //
  // Full API-failure fallback paths require injectable MoldCaseService
  // (add mockito/mocktail to dev_dependencies to enable those tests).
  // The following tests cover guard conditions that short-circuit before
  // any network call is made.

  group('CultureSessionService guard conditions', () {
    final service = CultureSessionService.instance;

    test('getAll returns empty list for empty caseId', () async {
      final result = await service.getAll(caseId: '');
      expect(result, isEmpty);
    });

    test('getAll returns empty list for whitespace-only caseId', () async {
      final result = await service.getAll(caseId: '   ');
      expect(result, isEmpty);
    });

    test('getAvailableForLogs returns empty list for empty caseId', () async {
      final result = await service.getAvailableForLogs('');
      expect(result, isEmpty);
    });

    test('createCulture returns null for empty caseId', () async {
      final result = await service.createCulture(
        caseId: '',
        name: 'Batch',
        targetAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(result, isNull);
    });

    test('createCulture returns null for whitespace-only name', () async {
      final result = await service.createCulture(
        caseId: 'case-1',
        name: '   ',
        targetAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(result, isNull);
    });

    test('endEarly returns false for empty caseId', () async {
      final result = await service.endEarly('sess-1', caseId: '');
      expect(result, isFalse);
    });

    test('endEarly returns false for empty cultureId', () async {
      final result = await service.endEarly('', caseId: 'case-1');
      expect(result, isFalse);
    });

    test('reassignTimer returns false for empty caseId', () async {
      final result = await service.reassignTimer(
        'sess-1',
        DateTime.now().add(const Duration(hours: 2)),
        caseId: '',
      );
      expect(result, isFalse);
    });

    test('reassignTimer returns false for empty cultureId', () async {
      final result = await service.reassignTimer(
        '',
        DateTime.now().add(const Duration(hours: 2)),
        caseId: 'case-1',
      );
      expect(result, isFalse);
    });

    test('deleteCulture returns false for empty caseId', () async {
      final result = await service.deleteCulture('sess-1', caseId: '');
      expect(result, isFalse);
    });

    test('deleteCulture returns false for empty cultureId', () async {
      final result = await service.deleteCulture('', caseId: 'case-1');
      expect(result, isFalse);
    });
  });
}
