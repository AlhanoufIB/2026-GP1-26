import 'package:flutter_test/flutter_test.dart';
import 'package:mullak/models/property.dart';
import 'package:mullak/repositories/property_repository.dart';

// Run with:  flutter test test/property_repository_test.dart
void main() {
  final repo = LocalPropertyRepository();

  test('Explore only gets available properties', () async {
    final list = await repo.getAvailableProperties();
    expect(list, isNotEmpty);
    expect(list.every((p) => p.status == PropertyStatus.available), isTrue);
    // The rented shop in Qurtubah must not be there
    expect(list.any((p) => p.propertyId == '10590'), isFalse);
  });

  test('Find one property by id', () async {
    final p = await repo.getPropertyById('10482');
    expect(p, isNotNull);
    expect(p!.district, 'العليا');
    expect(p.typeLabel, 'محل');
  });

  test('Unknown id returns null instead of crashing', () async {
    expect(await repo.getPropertyById('does-not-exist'), isNull);
  });

  test('Get several by ids keeps the given order and skips unknown ids',
      () async {
    final list = await repo.getPropertiesByIds(['10517', 'nope', '10482']);
    expect(list.map((p) => p.propertyId).toList(), ['10517', '10482']);
  });
}
