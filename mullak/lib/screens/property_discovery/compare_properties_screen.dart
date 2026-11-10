import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../repositories/property_repository.dart';
import '../../theme/app_colors.dart';
import 'utils/discovery_formatters.dart';

/// "مقارنة العقارات" — side-by-side table of 2 to 4 saved properties.
class ComparePropertiesScreen extends StatefulWidget {
  final List<String> propertyIds;

  /// propertyId -> match score (0-100). Empty until recommendations exist.
  final Map<String, int> matchScores;

  const ComparePropertiesScreen({
    super.key,
    required this.propertyIds,
    this.matchScores = const {},
  });

  @override
  State<ComparePropertiesScreen> createState() =>
      _ComparePropertiesScreenState();
}

class _ComparePropertiesScreenState extends State<ComparePropertiesScreen> {
  static const _green = Color(0xFF1F5A3A);
  static const _greenLight = Color(0xFFE3F8E3);
  static const _greenDark = Color(0xFF173A1E);

  List<Property>? _properties; // null while loading

  @override
  void initState() {
    super.initState();
    PropertyRepository.instance
        .getPropertiesByIds(widget.propertyIds)
        .then((list) {
      if (!mounted) return; // page was closed before loading finished
      setState(() => _properties = list);
    });
  }

  int? _scoreOf(Property p) => widget.matchScores[p.propertyId];

  /// Removes a property from the comparison (it stays saved).
  void _remove(String id) {
    setState(() => _properties!.removeWhere((p) => p.propertyId == id));
    if (_properties!.length < 2) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('تحتاج عقارين على الأقل للمقارنة')));
      Navigator.of(context).pop();
    }
  }

  /// Ids of the properties with the best value. Higher or lower wins.
  Set<String> _bestIds(List<Property> props, double Function(Property) value,
      {required bool higherIsBetter}) {
    final best = props.map(value).reduce((a, b) =>
        higherIsBetter ? math.max(a, b) : math.min(a, b));
    final ids =
        props.where((p) => value(p) == best).map((p) => p.propertyId).toSet();
    // if everyone ties, nobody is "best"
    return ids.length == props.length ? <String>{} : ids;
  }

  @override
  Widget build(BuildContext context) {
    final props = _properties;
    return Scaffold(
      body: SafeArea(
        child: props == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brown))
            : _buildContent(props),
      ),
    );
  }

  Widget _buildContent(List<Property> props) {
    final cheapest =
        _bestIds(props, (p) => p.rentPrice, higherIsBetter: false);
    final largest = _bestIds(props, (p) => p.areaSqm, higherIsBetter: true);
    final hasScores = widget.matchScores.isNotEmpty;
    final bestScore = hasScores
        ? _bestIds(props, (p) => (_scoreOf(p) ?? -1).toDouble(),
            higherIsBetter: true)
        : <String>{};

    // Recommended = most green cells; tie -> cheaper rent
    Property winner = props.first;
    var winnerPoints = -1;
    for (final p in props) {
      final points = [cheapest, largest, bestScore]
          .where((set) => set.contains(p.propertyId))
          .length;
      if (points > winnerPoints ||
          (points == winnerPoints && p.rentPrice < winner.rentPrice)) {
        winner = p;
        winnerPoints = points;
      }
    }
    final reasons = [
      if (bestScore.contains(winner.propertyId)) 'الأعلى ملاءمة لنشاطك',
      if (cheapest.contains(winner.propertyId)) 'الأقل سعراً',
      if (largest.contains(winner.propertyId)) 'الأكبر مساحة',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _buildHeader(),
        const SizedBox(height: 22),
        _buildTable(props, cheapest, largest, bestScore, hasScores),
        const SizedBox(height: 10),
        const Text(
          'اللون الأخضر يوضح الأفضل في كل صف.',
          style: TextStyle(fontSize: 12.5, color: AppColors.hint),
        ),
        const SizedBox(height: 24),
        _buildRecommended(winner, reasons),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: AppColors.brown, size: 18),
              SizedBox(width: 4),
              Text('المحفوظات',
                  style: TextStyle(
                      color: AppColors.brown, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'مقارنة العقارات',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark),
        ),
      ],
    );
  }

  Widget _buildTable(List<Property> props, Set<String> cheapest,
      Set<String> largest, Set<String> bestScore, bool hasScores) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const labelWidth = 82.0;
        // fill the screen with 2 properties, scroll sideways with 3-4
        final columnWidth = math.max(
            135.0, (constraints.maxWidth - labelWidth) / props.length);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                columnWidths: <int, TableColumnWidth>{
                  0: const FixedColumnWidth(labelWidth),
                  for (var i = 0; i < props.length; i++)
                    i + 1: FixedColumnWidth(columnWidth),
                },
                border: const TableBorder(
                  horizontalInside: BorderSide(color: AppColors.border),
                  verticalInside: BorderSide(color: AppColors.border),
                ),
                children: [
                  TableRow(
                    decoration:
                        const BoxDecoration(color: AppColors.gradientStart),
                    children: [
                      const SizedBox(),
                      for (final p in props) _headerCell(p),
                    ],
                  ),
                  _row('الموقع', props, (p) => p.district, const {}),
                  _row('سعر الإيجار', props,
                      (p) => formatYearlyRent(p.rentPrice), cheapest),
                  _row('المساحة', props, (p) => formatArea(p.areaSqm),
                      largest),
                  _row('نوع العقار', props, (p) => p.typeLabel, const {}),
                  if (hasScores)
                    _row('درجة الملاءمة', props, (p) {
                      final s = _scoreOf(p);
                      return s == null ? '—' : '$s%';
                    }, bestScore),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Top row: property title + "إزالة"
  Widget _headerCell(Property p) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.brownDark),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _remove(p.propertyId),
            child: const Text(
              'إزالة',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.brown,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One data row: grey label on the right, then one cell per property.
  TableRow _row(String label, List<Property> props,
      String Function(Property) valueOf, Set<String> bestIds) {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.background),
      children: [
        Padding(
          // this padding decides the row height
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.hint)),
        ),
        for (final p in props)
          TableCell(
            // stretch the cell to the full row height so the color fills it
            verticalAlignment: TableCellVerticalAlignment.fill,
            child: Container(
              color: bestIds.contains(p.propertyId)
                  ? _greenLight
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                valueOf(p),
                maxLines: 2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: bestIds.contains(p.propertyId)
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: bestIds.contains(p.propertyId)
                      ? _green
                      : AppColors.brownDark,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Dark green "العقار المرشح" box
  Widget _buildRecommended(Property winner, List<String> reasons) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: _greenDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('العقار المرشح :',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            winner.title,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            reasons.isEmpty
                ? 'الأفضل توازناً بين السعر والمساحة.'
                : '${reasons.join(' ، ')}.',
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}