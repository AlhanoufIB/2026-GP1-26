import '../models/business_requirement.dart';

/// Saves and reads the business owner's requirements.
/// Same idea as PropertyRepository: swap for Firestore in sprint 5.
abstract class BusinessRequirementRepository {
  static BusinessRequirementRepository instance =
      LocalBusinessRequirementRepository();

  /// Saves a new requirement and returns it with its generated id.
  Future<BusinessRequirement> save({
    required String businessOwnerId,
    required String businessType,
    required double budget,
    required double requiredSpace,
    String? preferredLocation,
    String? otherRequirements,
  });

  /// The most recent requirement of this owner, or null if none yet.
  Future<BusinessRequirement?> getLatest(String businessOwnerId);
}

/// TEMPORARY: keeps requirements in memory.
class LocalBusinessRequirementRepository
    implements BusinessRequirementRepository {
  final List<BusinessRequirement> _all = [];
  int _nextId = 1;

  @override
  Future<BusinessRequirement> save({
    required String businessOwnerId,
    required String businessType,
    required double budget,
    required double requiredSpace,
    String? preferredLocation,
    String? otherRequirements,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final requirement = BusinessRequirement(
      requirementId: 'req_${_nextId++}',
      businessOwnerId: businessOwnerId,
      businessType: businessType,
      budget: budget,
      requiredSpace: requiredSpace,
      preferredLocation: preferredLocation,
      otherRequirements: otherRequirements,
    );
    _all.add(requirement);
    return requirement;
  }

  @override
  Future<BusinessRequirement?> getLatest(String businessOwnerId) async {
    for (final r in _all.reversed) {
      if (r.businessOwnerId == businessOwnerId) return r;
    }
    return null;
  }
}