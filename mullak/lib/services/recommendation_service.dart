import 'package:flutter/foundation.dart';

import '../dataconnect_generated/generated.dart';
import '../models/business_requirement.dart';
import '../models/property.dart';
import '../models/recommendation.dart';
import '../repositories/property_repository.dart';

/// Where recommendations come from.
/// Today: simple rules. Later: the team's AI model (through the backend API).
/// To switch, write AiRecommendationService and change [instance].
/// The Recommendations page does not need to change.
abstract class RecommendationService {
  static RecommendationService instance =
      StoringRecommendationService(RuleBasedRecommendationService());

  /// Best properties for this requirement, best first (max 3).
  Future<List<Recommendation>> getRecommendations(
      BusinessRequirement requirement);
}

/// TEMPORARY rule-based scoring for Release 1 (NOT the AI model).
///
/// Weights come from questionnaire Q11 (see Recommendation):
///   location 34 + budget 34 + space 19 + parking 13 = 100
/// Each factor gives a fraction (0-1) of its weight:
///   location: 1 in the preferred district (or no preference), else 0
///   budget:   1 if rent <= budget, else budget / rent
///   space:    1 if area >= required, else area / required
///   parking:  1 if the property has parking, else 0
/// Property type and activity are the user's explicit choices, so
/// matching properties are listed first, then sorted by the score.
class RuleBasedRecommendationService implements RecommendationService {
  static const int maxResults = 3; // ER diagram: 0..3 per requirement

  @override
  Future<List<Recommendation>> getRecommendations(
      BusinessRequirement requirement) async {
    final properties =
        await PropertyRepository.instance.getAvailableProperties();

    // how well type/activity match: 2 = both, 1 = type only, 0 = none
    int typeLevel(Property p) =>
        (p.propertyType == requirement.propertyType ? 1 : 0) +
        (p.propertyType == requirement.propertyType &&
                p.activityType == requirement.businessType
            ? 1
            : 0);

    final scored = properties.map((p) => _score(requirement, p)).toList()
      ..sort((a, b) {
        final byType = typeLevel(b.property) - typeLevel(a.property);
        if (byType != 0) return byType; // matching types first
        return b.overallScore.compareTo(a.overallScore); // then by score
      });

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
          budgetPoints: top[i].budgetPoints,
          spacePoints: top[i].spacePoints,
          parkingPoints: top[i].parkingPoints,
          rank: i + 1,
        ),
    ];
  }

  Recommendation _score(BusinessRequirement req, Property p) {
    final reasons = <String>[];
    final tags = <String>[];

    // --- location (0-1) ---
    final preferred = req.preferredLocation?.trim();
    double location;
    if (preferred == null || preferred.isEmpty) {
      location = 1; // no preference -> no requirement missed
    } else if (p.district.contains(preferred) ||
        preferred.contains(p.district)) {
      location = 1;
      reasons.add('في موقعك المفضّل');
      tags.add('الموقع المفضّل');
    } else {
      location = 0;
      reasons.add('خارج الحي المفضّل');
    }

    // --- budget (0-1) ---
    double budget;
    if (p.rentPrice <= req.budget) {
      budget = 1;
      reasons.add('ضمن ميزانيتك');
      tags.add('ضمن الميزانية');
    } else {
      budget = req.budget / p.rentPrice; // e.g. 20% over -> 0.83
      reasons.add('السعر أعلى من ميزانيتك');
    }

    // --- space (0-1) ---
    double space;
    if (p.areaSqm >= req.requiredSpace) {
      space = 1;
      tags.add('مساحة مناسبة');
    } else {
      space = p.areaSqm / req.requiredSpace;
      reasons.add('مساحة أصغر من المطلوب');
    }

    // --- parking (0-1) ---
    final parking = p.hasParking == true ? 1.0 : 0.0;
    if (parking == 1) tags.add('مواقف');

    // --- type & activity: not weighted, used for ordering + tags ---
    if (p.propertyType == req.propertyType) {
      tags.add('نوع العقار المطلوب');
      if (p.activityType == req.businessType) {
        reasons.add('مناسب لنشاطك');
        tags.add('مناسب لنشاطك');
      }
    } else {
      reasons.add('نوع العقار مختلف عن المطلوب');
    }

    final budgetPoints = budget * Recommendation.budgetWeight;
    final spacePoints = space * Recommendation.spaceWeight;
    final parkingPoints = parking * Recommendation.parkingWeight;
    const matchWeight = Recommendation.budgetWeight +
        Recommendation.spaceWeight +
        Recommendation.parkingWeight; // 66

    return Recommendation(
      recommendationId: '', // set after sorting
      requirementId: req.requirementId,
      property: p,
      locationScore: location * 100,
      // stored as 0-100 so it fits the RECOMMENDATION table
      propertyMatchScore:
          (budgetPoints + spacePoints + parkingPoints) / matchWeight * 100,
      explanation: 'السبب: ${reasons.join('، ')}.',
      tags: tags,
      budgetPoints: budgetPoints,
      spacePoints: spacePoints,
      parkingPoints: parkingPoints,
      rank: 0, // set after sorting
    );
  }
}

/// Takes the results of another service (today: the rule-based one,
/// later: the AI model) and stores them in the RECOMMENDATION table,
/// one row per result with rank 1..3.
class StoringRecommendationService implements RecommendationService {
  final RecommendationService inner;
  final MullakConnector _db = MullakConnector.instance;
  final Set<String> _storedFor = {}; // requirements already stored

  StoringRecommendationService(this.inner);

  @override
  Future<List<Recommendation>> getRecommendations(
      BusinessRequirement requirement) async {
    final results = await inner.getRecommendations(requirement);
    if (!_storedFor.add(requirement.requirementId)) return results;
    for (final r in results) {
      try {
        await _db
            .createRecommendation(
              requirementId: requirement.requirementId,
              propertyId: r.property.propertyId,
              locationScore: r.locationScore,
              propertyMatchScore: r.propertyMatchScore,
              explanation: r.explanation,
              rank: r.rank,
            )
            .execute();
      } catch (e) {
        // showing the results matters more than storing them
        debugPrint('Could not store recommendation ${r.rank}: $e');
      }
    }
    return results;
  }
}