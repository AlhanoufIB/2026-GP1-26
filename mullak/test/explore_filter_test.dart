import 'package:flutter_test/flutter_test.dart';
import 'package:mullak/data/sample_properties.dart';
import 'package:mullak/models/property.dart';
import 'package:mullak/screens/property_discovery/utils/discovery_formatters.dart';
import 'package:mullak/screens/property_discovery/utils/explore_filter.dart';

// Run with:  flutter test test/explore_filter_test.dart
void main() {
  final available = sampleProperties.where((p) => p.isAvailable).toList();

     group('ExploreFilter', () {
    test('no filter shows everything', () {
      const filter = ExploreFilter();
      expect(filter.isAll, isTrue);
      expect(filter.apply(available).length, available.length);
    });

    test('type keeps only that type', () {
      final result =
          const ExploreFilter(type: PropertyType.shop).apply(available);
      expect(result, isNotEmpty);
      expect(result.every((p) => p.propertyType == PropertyType.shop), isTrue);
    });

    test('budget range keeps rents inside it', () {
      final result = const ExploreFilter(minBudget: 50000, maxBudget: 100000)
          .apply(available);
      expect(
        result.every((p) => p.rentPrice >= 50000 && p.rentPrice <= 100000),
        isTrue,
      );
    });

    test('space range keeps areas inside it', () {
      final result =
          const ExploreFilter(minSpace: 50, maxSpace: 150).apply(available);
      expect(
        result.every((p) => p.areaSqm >= 50 && p.areaSqm <= 150),
        isTrue,
      );
    });

    test('active count: type + budget + space = 3', () {
      const filter = ExploreFilter(
        type: PropertyType.shop,
        maxBudget: 100000,
        minSpace: 50,
      );
      expect(filter.activeCount, 3);
    });
  });

  group('formatters', () {
    test('rent with commas', () {
      expect(formatYearlyRent(78000), '78,000 ر.س / سنة');
      expect(formatNumber(1250000), '1,250,000');
      expect(formatNumber(950), '950');
    });

    test('area', () {
      expect(formatArea(85), '85 م²');
      expect(formatArea(85.5), '85.5 م²');
    });
  });
}
