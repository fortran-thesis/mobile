import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';

void main() {
  group('CultivationDetails', () {
    group('fromJson & toJson round-trip', () {
      test('should preserve specimen_types array', () {
        final original = {
          'growth_medium': 'PDA',
          'specimen_types': ['Leaf', 'Stem', 'Root'],
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.specimenTypes, equals(['Leaf', 'Stem', 'Root']));

        final json = details.toJson();
        expect(json['specimen_types'], equals(['Leaf', 'Stem', 'Root']));
      });

      test('should preserve specimen_quantities array', () {
        final original = {
          'growth_medium': 'PDA',
          'specimen_quantities': ['5', '3', '2'],
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.specimenQuantities, equals(['5', '3', '2']));

        final json = details.toJson();
        expect(json['specimen_quantities'], equals(['5', '3', '2']));
      });

      test('should preserve initial_symptoms array', () {
        final original = {
          'growth_medium': 'PDA',
          'initial_symptoms': ['Leaf spots', 'Wilting', 'Yellowing'],
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.initialSymptoms,
            equals(['Leaf spots', 'Wilting', 'Yellowing']));

        final json = details.toJson();
        expect(json['initial_symptoms'],
            equals(['Leaf spots', 'Wilting', 'Yellowing']));
      });

      test('should preserve initial_characteristics array', () {
        final original = {
          'growth_medium': 'PDA',
          'initial_characteristics': ['Cottony', 'Fuzzy', 'Powdery'],
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.initialCharacteristics,
            equals(['Cottony', 'Fuzzy', 'Powdery']));

        final json = details.toJson();
        expect(json['initial_characteristics'],
            equals(['Cottony', 'Fuzzy', 'Powdery']));
      });

      test('should preserve location_gathered string', () {
        final original = {
          'growth_medium': 'PDA',
          'location_gathered': 'Northwest field, plot 5',
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.locationGathered, equals('Northwest field, plot 5'));

        final json = details.toJson();
        expect(json['location_gathered'], equals('Northwest field, plot 5'));
      });

      test('should handle full monitoring setup payload', () {
        final original = {
          'growth_medium': 'Potato Dextrose Agar',
          'specimen_types': ['Leaf', 'Stem'],
          'specimen_quantities': ['5', '3'],
          'initial_symptoms': ['Leaf spots', 'Wilting'],
          'initial_characteristics': ['Cottony', 'Powdery'],
          'location_gathered': 'Farm A',
          'in_vivo_details': {'environmental_temperature': 25.5},
          'in_vitro_details': {'incubation_temperature': 28.0},
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.growthMedium, equals('Potato Dextrose Agar'));
        expect(details.specimenTypes, equals(['Leaf', 'Stem']));
        expect(details.specimenQuantities, equals(['5', '3']));
        expect(details.initialSymptoms, equals(['Leaf spots', 'Wilting']));
        expect(
            details.initialCharacteristics, equals(['Cottony', 'Powdery']));
        expect(details.locationGathered, equals('Farm A'));
        expect(details.inVivoDetails?.environmentalTemperature, equals(25.5));
        expect(details.inVitroDetails?.incubationTemperature, equals(28.0));

        final json = details.toJson();
        expect(json['specimen_types'], equals(['Leaf', 'Stem']));
        expect(json['specimen_quantities'], equals(['5', '3']));
        expect(json['initial_symptoms'], equals(['Leaf spots', 'Wilting']));
        expect(json['initial_characteristics'],
            equals(['Cottony', 'Powdery']));
        expect(json['location_gathered'], equals('Farm A'));
      });

      test('should handle missing optional fields', () {
        final original = {'growth_medium': 'PDA'};

        final details = CultivationDetails.fromJson(original);
        expect(details.growthMedium, equals('PDA'));
        expect(details.specimenTypes, isNull);
        expect(details.specimenQuantities, isNull);
        expect(details.initialSymptoms, isNull);
        expect(details.initialCharacteristics, isNull);
        expect(details.locationGathered, isNull);

        final json = details.toJson();
        expect(json.containsKey('specimen_types'), isFalse);
        expect(json.containsKey('specimen_quantities'), isFalse);
        expect(json.containsKey('initial_symptoms'), isFalse);
        expect(json.containsKey('initial_characteristics'), isFalse);
        expect(json.containsKey('location_gathered'), isFalse);
      });

      test('should handle empty arrays correctly', () {
        final original = {
          'growth_medium': 'PDA',
          'specimen_types': [],
          'initial_symptoms': [],
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.specimenTypes, equals([]));
        expect(details.initialSymptoms, equals([]));

        final json = details.toJson();
        expect(json['specimen_types'], equals([]));
        expect(json['initial_symptoms'], equals([]));
      });

      test('should fallback to null for non-list specimen_types', () {
        final original = {
          'growth_medium': 'PDA',
          'specimen_types': 'Leaf',
        };

        final details = CultivationDetails.fromJson(original);
        expect(details.specimenTypes, isNull);
      });
    });

    group('CultivationDetails.empty()', () {
      test('should initialize all optional fields to null', () {
        final empty = CultivationDetails.empty();
        expect(empty.growthMedium, equals(''));
        expect(empty.specimenTypes, isNull);
        expect(empty.specimenQuantities, isNull);
        expect(empty.initialSymptoms, isNull);
        expect(empty.initialCharacteristics, isNull);
        expect(empty.locationGathered, isNull);
      });
    });
  });
}
