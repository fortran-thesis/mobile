import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/core/features/mold/service/mold_detail_adapter.dart';

void main() {
  group('MoldDetailAdapter', () {
    test('unwrapPayload supports nested data envelopes', () {
      final payload = {
        'data': {
          'data': {
            'id': 'mold-1',
            'mold_details': {
              'info': {'overview': 'Nested overview'},
            },
          },
        },
      };

      final unwrapped = MoldDetailAdapter.unwrapPayload(payload);
      expect(unwrapped['id'], 'mold-1');
    });

    test('readField prefers scalar field over additional_info aliases', () {
      final payload = {
        'mold_details': {
          'info': {
            'overview': 'Canonical overview',
            'additional_info': [
              {'title': 'Overview', 'description': 'Legacy overview'},
            ],
          },
        },
      };

      final value = MoldDetailAdapter.readField(payload, 'overview');
      expect(value, 'Canonical overview');
    });

    test('readField falls back to legacy additional_info aliases', () {
      final payload = {
        'mold_details': {
          'info': {
            'additional_info': [
              {
                'title': 'Disease Cycle Spread',
                'description': 'Spread increases with humidity',
              },
            ],
          },
        },
      };

      final value = MoldDetailAdapter.readField(
        payload,
        'disease_cycle_spread_impact',
      );
      expect(value, 'Spread increases with humidity');
    });
  });
}
