import 'package:flutter_test/flutter_test.dart';
import 'package:mullak/data/sample_properties.dart';
import 'package:mullak/models/property.dart';
import 'package:mullak/screens/property_discovery/utils/discovery_formatters.dart';
import 'package:mullak/screens/property_discovery/utils/explore_filter.dart';

// Run with:  flutter test test/explore_filter_test.dart
void main() {
  final available = sampleProperties.where((p) => p.isAvailable).toList();

  group('ExploreFilter', () {
    test('"الكل" shows everything', () {
      const filter = ExploreFilter();
      expect(filter.isAll, isTrue);
      expect(filter.apply(available).length, available.length);
    });

    test('"محلات" shows only shops', () {
      final result =
          const ExploreFilter().toggleType(PropertyType.shop).apply(available);
      expect(result, isNotEmpty);
      expect(result.every((p) => p.propertyType == PropertyType.shop), isTrue);
    });

    test('tapping the same type again clears it', () {
      final filter = const ExploreFilter()
          .toggleType(PropertyType.shop)
          .toggleType(PropertyType.shop);
      expect(filter.isAll, isTrue);
    });

    test('"أقل من 80 م²" keeps only areas under 80', () {
      final result = const ExploreFilter().toggleSmall().apply(available);
      expect(result.every((p) => p.areaSqm < 80), isTrue);
      // the 85 m² shop in Olaya must be filtered out
      expect(result.any((p) => p.propertyId == '10482'), isFalse);
    });

    test('type and area combine (shops under 80 m²)', () {
      final result = const ExploreFilter()
          .toggleType(PropertyType.shop)
          .toggleSmall()
          .apply(available);
      expect(
        result.every(
            (p) => p.propertyType == PropertyType.shop && p.areaSqm < 80),
        isTrue,
      );
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
