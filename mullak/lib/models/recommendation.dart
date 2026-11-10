import 'property.dart';

/// One recommended property for one business requirement.
/// Fields follow RECOMMENDATION in our data dictionary (4.4.2).
class Recommendation {
  final String recommendationId; // PK
  final String requirementId; // FK -> Business_Requirement
  final Property property; // the recommended property (property_id)
  final double locationScore; // 0-100
  final double propertyMatchScore; // 0-100
  final String explanation; // why it was recommended
  final int rank; // 1 = best

  /// Short labels shown on the card, e.g. "ضمن الميزانية".
  /// PENDING TEAM DECISION: not stored in the data dictionary yet.
  final List<String> tags;

  const Recommendation({
    required this.recommendationId,
    required this.requirementId,
    required this.property,
    required this.locationScore,
    required this.propertyMatchScore,
    required this.explanation,
    required this.rank,
    this.tags = const [],
  });

  /// The single % shown in the UI.
  /// TEMPORARY formula (simple average) until the team decides how the
  /// AI model's two scores combine. Change it here only.
  int get overallScore =>
      ((locationScore + propertyMatchScore) / 2).round().clamp(0, 100).toInt();
}
