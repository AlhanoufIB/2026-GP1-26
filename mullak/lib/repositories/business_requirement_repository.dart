import 'package:firebase_auth/firebase_auth.dart';

import '../dataconnect_generated/generated.dart';
import '../models/business_requirement.dart';

/// Saves and reads the business owner's requirements
/// (BUSINESS_REQUIREMENT table in the database).
abstract class BusinessRequirementRepository {
  static BusinessRequirementRepository instance =
      DataConnectBusinessRequirementRepository();

  /// Saves a new requirement and returns it with its database id.
  Future<BusinessRequirement> save({
    required String businessOwnerId,
    required String businessType,
    required String propertyType,
    required double budget,
    required double requiredSpace,
    String? preferredLocation,
    String? otherRequirements,
  });

  /// The most recent requirement saved in this session, or null.
  Future<BusinessRequirement?> getLatest(String businessOwnerId);
}

/// Real database version (Firebase Data Connect).
class DataConnectBusinessRequirementRepository
    implements BusinessRequirementRepository {
  final MullakConnector _db = MullakConnector.instance;

  /// Kept to pre-fill the form when the user comes back to it.
  /// (The table has no date column in the ER, so the database
  /// can't tell which requirement is the latest.)
  BusinessRequirement? _lastSaved;

  @override
  Future<BusinessRequirement> save({
    required String businessOwnerId,
    required String businessType,
    required String propertyType,
    required double budget,
    required double requiredSpace,
    String? preferredLocation,
    String? otherRequirements,
  }) async {
    // same answers as last time? reuse it instead of a new row
    final last = _lastSaved;
    if (last != null &&
        last.businessType == businessType &&
        last.propertyType == propertyType &&
        last.budget == budget &&
        last.requiredSpace == requiredSpace &&
        last.preferredLocation == preferredLocation) {
      return last;
    }
    final result = await _db
        .createBusinessRequirement(
          businessType: businessType,
          propertyType: propertyType,
          budget: budget,
          requiredSpace: requiredSpace,
        )
        .preferredLocation(preferredLocation) // optional
        .execute();

    final requirement = BusinessRequirement(
      // the id the database just created for this row
      requirementId: result.data.businessRequirement_insert.id,
      // the database stores the signed-in user (auth.uid) as the owner
      businessOwnerId:
          FirebaseAuth.instance.currentUser?.uid ?? businessOwnerId,
      businessType: businessType,
      propertyType: propertyType,
      budget: budget,
      requiredSpace: requiredSpace,
      preferredLocation: preferredLocation,
      otherRequirements: otherRequirements, // not in the ER -> not stored
    );
    _lastSaved = requirement;
    return requirement;
  }

  @override
  Future<BusinessRequirement?> getLatest(String businessOwnerId) async =>
      _lastSaved;
}
