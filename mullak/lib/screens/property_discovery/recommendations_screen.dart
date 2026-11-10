import 'package:flutter/material.dart';

import '../../models/business_requirement.dart';
import '../../models/recommendation.dart';
import '../../repositories/saved_properties_repository.dart';
import '../../services/recommendation_service.dart';
import '../../theme/app_colors.dart';
import 'property_details_screen.dart';
import 'utils/discovery_formatters.dart';

/// "أنسب العقارات لنشاطك" — ranked recommendations with reasons.
///
/// Backlog story: "As a business owner, I want to receive property
/// recommendations so that I can choose a suitable location."
class RecommendationsScreen extends StatefulWidget {
  final BusinessRequirement requirement;

  const RecommendationsScreen({super.key, required this.requirement});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late Future<List<Recommendation>> _future;

  @override
  void initState() {
    super.initState();
    _future =
        RecommendationService.instance.getRecommendations(widget.requirement);
  }

  /// Retry button: ask the service again.
  void _load() {
    setState(() {
      _future = RecommendationService.instance
          .getRecommendations(widget.requirement);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Recommendation>>(
          future: _future,
          builder: (context, snapshot) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                ..._buildResults(snapshot),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          // back to the form, which still has the answers filled in
          onTap: () => Navigator.of(context).pop(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: AppColors.brown, size: 18),
              SizedBox(width: 4),
              Text(
                'تعديل المتطلبات',
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'أنسب العقارات لـ${widget.requirement.businessType}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'مرتبة حسب درجة الملاءمة. اضغط على العقار لمعرفة التفاصيل.',
          style: TextStyle(fontSize: 14, color: AppColors.hint),
        ),
      ],
    );
  }

  List<Widget> _buildResults(AsyncSnapshot<List<Recommendation>> snapshot) {
    // 1) loading
    if (snapshot.connectionState != ConnectionState.done) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brown),
          ),
        ),
      ];
    }

    // 2) failed (backlog: inform the user instead of showing wrong results)
    if (snapshot.hasError) {
      return [
        _Message(
          icon: Icons.error_outline,
          text: 'تعذّر إنشاء الترشيحات حالياً. حاول مرة أخرى.',
          actionLabel: 'إعادة المحاولة',
          onAction: _load,
        ),
      ];
    }

    // 3) no matches
    final recommendations = snapshot.data ?? const [];
    if (recommendations.isEmpty) {
      return const [
        _Message(
          icon: Icons.search_off_rounded,
          text:
              'لا توجد عقارات مناسبة حالياً.\nجرّب تعديل الميزانية أو المساحة.',
        ),
      ];
    }

    // 4) results
    return [
      for (final r in recommendations)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _RecommendationCard(
            recommendation: r,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailsScreen(
                  property: r.property,
                  matchScore: r.overallScore, // shows the green badge
                ),
              ),
            ),
          ),
        ),
    ];
  }
}

/// One recommendation: score ring, title, save button, reason, tags.
class _RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onTap;

  const _RecommendationCard({required this.recommendation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = recommendation.property;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ScoreRing(score: recommendation.overallScore),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brownDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatArea(p.areaSqm)} · ${formatYearlyRent(p.rentPrice)}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SaveButton(propertyId: p.propertyId),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                recommendation.explanation,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: AppColors.hint,
                ),
              ),
              if (recommendation.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in recommendation.tags) _Tag(text: tag),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The circle with the % in the middle.
/// Green = good match, amber = medium, red = weak.
class _ScoreRing extends StatelessWidget {
  final int score;

  const _ScoreRing({required this.score});

  Color get _color {
    if (score >= 70) return const Color(0xFF2E6B4F);
    if (score >= 40) return const Color(0xFFC98A2B);
    return const Color(0xFFC0392B);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 7,
              color: _color,
              backgroundColor: AppColors.gradientStart,
            ),
          ),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Square bookmark button. Uses the same saved list as the details page.
class _SaveButton extends StatelessWidget {
  final String propertyId;

  const _SaveButton({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final saved = SavedPropertiesRepository.instance;
    return ListenableBuilder(
      listenable: saved,
      builder: (context, _) {
        final isSaved = saved.isSaved(propertyId);
        return Material(
          color: AppColors.gradientStart,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => saved.toggle(propertyId),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.brown,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small beige label, e.g. "ضمن الميزانية".
class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gradientStart,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.brown,
        ),
      ),
    );
  }
}

/// Empty and error states.
class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.hint),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.hint),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
