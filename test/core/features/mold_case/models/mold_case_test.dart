import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';

void main() {
  group('CultivationLog', () {
    group('fromJson & toJson round-trip', () {
      test('should preserve culture_id and culture_name from characteristics map', () {
        final json = {
          'id': 'log-1',
          'type': 'vitro',
          'characteristics': {
            'color': 'white',
            'texture': 'cottony',
            'culture_id': 'culture-sess-001',
            'culture_name': 'Batch Alpha',
          },
          'additional_info': '',
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.characteristics['culture_id'], equals('culture-sess-001'));
        expect(log.characteristics['culture_name'], equals('Batch Alpha'));
        expect(log.characteristics['color'], equals('white'));

        final out = log.toJson();
        expect((out['characteristics'] as Map)['culture_id'], equals('culture-sess-001'));
        expect((out['characteristics'] as Map)['culture_name'], equals('Batch Alpha'));
      });

      test('should parse characteristics from a JSON-encoded string', () {
        final encoded = jsonEncode({
          'color': 'olive',
          'culture_id': 'culture-sess-002',
          'culture_name': 'Batch Beta',
        });

        final json = {
          'id': 'log-2',
          'type': 'vivo',
          'characteristics': encoded,
          'additional_info': '',
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.characteristics['culture_id'], equals('culture-sess-002'));
        expect(log.characteristics['culture_name'], equals('Batch Beta'));
      });

      test('should produce empty characteristics map when characteristics is an invalid string', () {
        final json = {
          'id': 'log-3',
          'type': 'vivo',
          'characteristics': 'not-valid-json',
          'additional_info': '',
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.characteristics, isEmpty);
      });

      test('should not include culture fields when they are absent', () {
        final json = {
          'id': 'log-4',
          'type': 'vitro',
          'characteristics': {
            'color': 'black',
            'macro_texture': 'powdery',
          },
          'additional_info': '',
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.characteristics.containsKey('culture_id'), isFalse);
        expect(log.characteristics.containsKey('culture_name'), isFalse);
      });
    });

    group('additionalInfo parsing', () {
      test('should parse additionalInfo from a plain string', () {
        final json = {
          'id': 'log-5',
          'type': 'vivo',
          'characteristics': <String, dynamic>{},
          'additional_info': 'Plain note',
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.additionalInfo, equals('Plain note'));
      });

      test('should parse additionalInfo from a list of items', () {
        final json = {
          'id': 'log-6',
          'type': 'vivo',
          'characteristics': <String, dynamic>{},
          'additional_info': [
            {'title': 'Observation', 'description': 'Mycelium spreading'},
            {'title': 'Follow-up', 'content': 'Resample at day 7'},
          ],
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.additionalInfo, contains('Observation: Mycelium spreading'));
        expect(log.additionalInfo, contains('Follow-up: Resample at day 7'));
      });

      test('should parse additionalInfo from a map with description', () {
        final json = {
          'id': 'log-7',
          'type': 'vitro',
          'characteristics': <String, dynamic>{},
          'additional_info': {
            'title': 'Status',
            'description': 'Stable growth',
          },
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.additionalInfo, equals('Status: Stable growth'));
      });

      test('should return empty string for null additionalInfo', () {
        final json = {
          'id': 'log-8',
          'type': 'vivo',
          'characteristics': <String, dynamic>{},
          'additional_info': null,
          'image_url': '',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.additionalInfo, isEmpty);
      });
    });

    group('createdAt parsing', () {
      test('should parse createdAt from _seconds timestamp map', () {
        final seconds = DateTime(2024, 3, 15).millisecondsSinceEpoch ~/ 1000;
        final json = {
          'id': 'log-9',
          'type': 'vivo',
          'characteristics': <String, dynamic>{},
          'additional_info': '',
          'image_url': '',
          'created_at': {'_seconds': seconds, '_nanoseconds': 0},
        };

        final log = CultivationLog.fromJson(json);
        expect(log.createdAt, isNotNull);
        expect(log.createdAt!.millisecondsSinceEpoch ~/ 1000, equals(seconds));
      });

      test('should parse createdAt from ISO string', () {
        final json = {
          'id': 'log-10',
          'type': 'vitro',
          'characteristics': <String, dynamic>{},
          'additional_info': '',
          'image_url': '',
          'created_at': '2024-06-01T12:00:00.000Z',
        };

        final log = CultivationLog.fromJson(json);
        expect(log.createdAt, isNotNull);
        expect(log.createdAt!.year, equals(2024));
        expect(log.createdAt!.month, equals(6));
      });

      test('should fall back to metadata.created_at when created_at is absent', () {
        final seconds = DateTime(2024, 1, 10).millisecondsSinceEpoch ~/ 1000;
        final json = {
          'id': 'log-11',
          'type': 'vivo',
          'characteristics': <String, dynamic>{},
          'additional_info': '',
          'image_url': '',
          'metadata': {
            'created_at': {'_seconds': seconds},
          },
        };

        final log = CultivationLog.fromJson(json);
        expect(log.createdAt, isNotNull);
        expect(log.createdAt!.millisecondsSinceEpoch ~/ 1000, equals(seconds));
      });
    });

    group('toJson', () {
      test('should serialize type, characteristics, and imageUrl', () {
        final json = {
          'id': 'log-12',
          'type': 'vitro',
          'characteristics': {
            'culture_id': 'c-1',
            'culture_name': 'Test Batch',
          },
          'additional_info': 'note',
          'image_url': 'https://example.com/img.jpg',
        };

        final log = CultivationLog.fromJson(json);
        final out = log.toJson();

        expect(out['id'], equals('log-12'));
        expect(out['type'], equals('vitro'));
        expect((out['characteristics'] as Map)['culture_name'], equals('Test Batch'));
        expect(out['image_url'], equals('https://example.com/img.jpg'));
        expect(out['additional_info'], equals('note'));
      });
    });
  });
}
