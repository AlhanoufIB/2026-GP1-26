import 'property.dart';

/// One recommended property for one business requirement.
/// Fields follow RECOMMENDATION in our data dictionary (4.4.2).
class Recommendation {
  // Weights from questionnaire Q11 (n = 43): votes of the factors we can
  // measure in Release 1 -> location 39, budget 39, space 22, parking 16
  // (total 116). Weight = votes / 116, rounded to sum to 100.
  static const double locationWeight = 34;
  static const double budgetWeight = 34;
  static const double spaceWeight = 19;
  static const double parkingWeight = 13;

  final String recommendationId; // PK
  final String requirementId; // FK -> Business_Requirement
  final Property property; // the recommended property (property_id)
  final double locationScore; // 0-100 (stored)
  final double propertyMatchScore; // 0-100 (stored): budget+space+parking
  final String explanation; // why it was recommended
  final int rank; // 1 = best
  final List<String> tags;

  // breakdown shown in the "كيف حُسبت النسبة؟" sheet (not stored)
  final double budgetPoints; // 0-34
  final double spacePoints; // 0-19
  final double parkingPoints; // 0-13

  const Recommendation({
    required this.recommendationId,
    required this.requirementId,
    required this.property,
    required this.locationScore,
    required this.propertyMatchScore,
    required this.explanation,
    required this.rank,
    this.tags = const [],
    this.budgetPoints = 0,
    this.spacePoints = 0,
    this.parkingPoints = 0,
  });

  /// Location share of the total (0-34).
  double get locationPoints => locationScore / 100 * locationWeight;

  /// The single % shown in the UI = location 34% + property match 66%.
  int get overallScore {
    const matchWeight = budgetWeight + spaceWeight + parkingWeight; // 66
    final total = locationScore / 100 * locationWeight +
        propertyMatchScore / 100 * matchWeight;
    return total.round().clamp(0, 100).toInt();
  }
}