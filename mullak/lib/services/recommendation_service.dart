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

/// TEMPORARY placeholder scoring. This is NOT the AI model.
///
/// property_match_score (0-100):
///   budget  up to 50 (full if rent <= budget, less the more it's over)
///   space   up to 30 (full if area >= required, less if smaller)
///   type    20       (same property type 10 + same activity 10)
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
          budgetPoints: top[i].budgetPoints,
          spacePoints: top[i].spacePoints,
          typePoints: top[i].typePoints,
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

    // --- property type + activity: up to 20 points ---
    // exact match: both forms pick from the same lists
    double typePoints = 0;
    if (p.propertyType == req.propertyType) {
      typePoints += 10;
      tags.add('نوع العقار المطلوب');
    } else {
      reasons.add('نوع العقار مختلف عن المطلوب');
    }
    if (p.activityType == req.businessType) {
      typePoints += 10;
      reasons.add('مناسب لنشاطك');
      tags.add('مناسب لنشاطك');
    }

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
      budgetPoints: budgetPoints,
      spacePoints: spacePoints,
      typePoints: typePoints,
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