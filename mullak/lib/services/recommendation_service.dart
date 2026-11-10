import '../models/business_requirement.dart';
import '../models/property.dart';
import '../models/recommendation.dart';
import '../repositories/property_repository.dart';

/// Where recommendations come from.
/// Today: simple rules. Later: the team's AI model (through the backend API).
/// To switch, write AiRecommendationService and change [instance].
/// The Recommendations page does not need to change.
abstract class RecommendationService {
  static RecommendationService instance = RuleBasedRecommendationService();

  /// Best properties for this requirement, best first (max 3).
  Future<List<Recommendation>> getRecommendations(
      BusinessRequirement requirement);
}

/// TEMPORARY placeholder scoring. This is NOT the AI model.
///
/// property_match_score (0-100):
///   budget  up to 50 (full if rent <= budget, less the more it's over)
///   space   up to 30 (full if area >= required, less if smaller)
///   type    20       (office businesses -> offices, others -> shops/kiosks)
/// location_score (0-100):
///   100 in the preferred district, 40 elsewhere, 60 if none was chosen.
class RuleBasedRecommendationService implements RecommendationService {
  static const int maxResults = 3; // ER diagram: 0..3 per requirement

  @override
  Future<List<Recommendation>> getRecommendations(
      BusinessRequirement requirement) async {
    final properties =
        await PropertyRepository.instance.getAvailableProperties();

    final scored = properties.map((p) => _score(requirement, p)).toList()
      ..sort((a, b) => b.overallScore.compareTo(a.overallScore));

    final top = scored.take(maxResults).toList();
    return [
      for (var i = 0; i < top.length; i++)
        Recommendation(
          recommendationId: '${requirement.requirementId}_${i + 1}',
          requirementId: requirement.requirementId,
          property: top[i].property,
          locationScore: top[i].locationScore,
          propertyMatchScore: top[i].propertyMatchScore,
          explanation: top[i].explanation,
          tags: top[i].tags,
          rank: i + 1,
        ),
    ];
  }

  Recommendation _score(BusinessRequirement req, Property p) {
    final reasons = <String>[];
    final tags = <String>[];

    // --- budget: up to 50 points ---
    double budgetPoints;
    if (p.rentPrice <= req.budget) {
      budgetPoints = 50;
      reasons.add('ضمن ميزانيتك');
      tags.add('ضمن الميزانية');
    } else {
      final overBy = (p.rentPrice - req.budget) / req.budget; // 0.2 = 20%
      budgetPoints = (50 * (1 - overBy * 2)).clamp(0, 50).toDouble();
      reasons.add('السعر أعلى من ميزانيتك');
    }

    // --- space: up to 30 points ---
    double spacePoints;
    if (p.areaSqm >= req.requiredSpace) {
      spacePoints = 30;
      tags.add('مساحة مناسبة');
    } else {
      spacePoints = 30 * (p.areaSqm / req.requiredSpace);
      reasons.add('مساحة أصغر من المطلوب');
    }

    // --- property type: 20 points ---
    final typePoints =
        _typeFits(req.businessType, p.propertyType) ? 20.0 : 0.0;
    if (typePoints == 0) reasons.add('نوع العقار أقل ملاءمة لنشاطك');

    // --- location: separate 0-100 score ---
    double locationScore;
    final preferred = req.preferredLocation?.trim();
    if (preferred == null || preferred.isEmpty) {
      locationScore = 60; // neutral: the user did not choose a district
    } else if (p.district.contains(preferred) ||
        preferred.contains(p.district)) {
      locationScore = 100;
      reasons.add('في موقعك المفضّل');
      tags.add('الموقع المفضّل');
    } else {
      locationScore = 40;
    }

    if (p.hasParking == true) tags.add('مواقف');

    return Recommendation(
      recommendationId: '', // set after sorting
      requirementId: req.requirementId,
      property: p,
      locationScore: locationScore,
      propertyMatchScore: budgetPoints + spacePoints + typePoints,
      explanation: 'السبب: ${reasons.join('، ')}.',
      tags: tags,
      rank: 0, // set after sorting
    );
  }

  /// Very simple matching between the free-text business type and the
  /// property type. The AI model will replace this.
  bool _typeFits(String businessType, String propertyType) {
    const officeWords = ['مكتب', 'شركة', 'استشار', 'محاسب', 'تقنية'];
    final wantsOffice = officeWords.any(businessType.contains);
    if (wantsOffice) return propertyType == PropertyType.office;
    return propertyType == PropertyType.shop ||
        propertyType == PropertyType.kiosk;
  }
}
