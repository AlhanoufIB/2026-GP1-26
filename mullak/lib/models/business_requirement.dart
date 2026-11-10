/// What the business owner is looking for.
/// Fields follow BUSINESS_REQUIREMENT in our data dictionary (4.4.2).
class BusinessRequirement {
  final String requirementId; // PK
  final String businessOwnerId; // FK -> Business_Owner.user_ID
  final String businessType; // e.g. "مقهى"
  final double budget; // max yearly rent in SAR, > 0
  final double requiredSpace; // min area in m², > 0
  final String? preferredLocation; // optional district/area

  /// PENDING TEAM DECISION: not in the data dictionary yet ("متطلبات أخرى").
  final String? otherRequirements;

  const BusinessRequirement({
    required this.requirementId,
    required this.businessOwnerId,
    required this.businessType,
    required this.budget,
    required this.requiredSpace,
    this.preferredLocation,
    this.otherRequirements,
  });
}