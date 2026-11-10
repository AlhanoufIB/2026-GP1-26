import '../data/sample_properties.dart';
import '../models/property.dart';

/// The ONLY place pages get property data from.
///
/// Pages never touch the sample list or Firebase directly. They call these
/// methods. In sprint 5 we write `FirestorePropertyRepository` with the same
/// methods and change one line in [PropertyRepository.instance].
/// No page has to change. (This supports our Maintainability NFR.)
abstract class PropertyRepository {
  /// The one shared repository used by the whole app.
  static PropertyRepository instance = LocalPropertyRepository();

  /// All listings business owners are allowed to see (status = available).
  Future<List<Property>> getAvailableProperties();

  /// One listing by its id, or null if it does not exist.
  Future<Property?> getPropertyById(String propertyId);

  /// Several listings at once, in the same order as [ids].
  /// Ids that do not exist are skipped. Used by Saved and Compare.
  Future<List<Property>> getPropertiesByIds(List<String> ids);
}

/// Temporary implementation that reads from [sampleProperties].
class LocalPropertyRepository implements PropertyRepository {
  /// Fake network delay, so pages are built with real loading states
  /// from day one (Firestore calls are not instant either).
  static const _delay = Duration(milliseconds: 300);

  @override
  Future<List<Property>> getAvailableProperties() async {
    await Future.delayed(_delay);
    return sampleProperties.where((p) => p.isAvailable).toList();
  }

  @override
  Future<Property?> getPropertyById(String propertyId) async {
    await Future.delayed(_delay);
    for (final p in sampleProperties) {
      if (p.propertyId == propertyId) return p;
    }
    return null;
  }

  @override
  Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    await Future.delayed(_delay);
    final result = <Property>[];
    for (final id in ids) {
      for (final p in sampleProperties) {
        if (p.propertyId == id) result.add(p);
      }
    }
    return result;
  }
}
