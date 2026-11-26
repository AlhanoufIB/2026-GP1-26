import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../repositories/property_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import 'property_details_screen.dart';
import 'utils/discovery_formatters.dart';
import 'widgets/property_image.dart';

/// "مقارنة العقارات" — side-by-side comparison of 2 to 4 saved properties.
///
/// UX rules applied (NN/g, Baymard):
///  - one column per property, one row per attribute
///  - property cards (photo, title, price) at the top, tap -> details
///  - values colored best -> worst (green, yellow, orange, red) + an icon
///  - "show differences only" hides rows where all values are the same
///  - at least 2 properties: remove is hidden when only 2 are left
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
  static const _greenDark = Color(0xFF173A1E);

  List<Property>? _properties; // null while loading
  bool _onlyDifferences = false;

  @override
  void initState() {
    super.initState();
    PropertyRepository.instance.getPropertiesByIds(widget.propertyIds).then((
      list,
    ) {
      if (!mounted) return; // page was closed before loading finished
      setState(() => _properties = list);
    });
  }

  int? _scoreOf(Property p) => widget.matchScores[p.propertyId];

  /// Removes a property from the comparison (it stays saved),
  /// with "تراجع" to put it back in the same place.
  void _remove(Property p) {
    final index = _properties!.indexOf(p); // remember its position
    setState(() => _properties!.remove(p));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Text('تمت إزالة "${p.title}" من المقارنة'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () {
              if (!mounted) return; // page already closed
              setState(
                () =>
                    _properties!.insert(index.clamp(0, _properties!.length), p),
              );
            },
          ),
        ),
      );
  }

  void _openDetails(Property p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PropertyDetailsScreen(property: p, matchScore: _scoreOf(p)),
      ),
    );
  }

  /// Ids of the properties with the best value. If everyone ties: none.
  Set<String> _bestIds(
    List<Property> props,
    double Function(Property) value, {
    required bool higherIsBetter,
  }) {
    final best = props
        .map(value)
        .reduce((a, b) => higherIsBetter ? math.max(a, b) : math.min(a, b));
    final ids = props
        .where((p) => value(p) == best)
        .map((p) => p.propertyId)
        .toSet();
    return ids.length == props.length ? <String>{} : ids;
  }

  /// Ranks the properties on one value and gives each a color level:
  /// 2 different values -> green, red
  /// 3 -> green, yellow, red      4 -> green, yellow, orange, red
  /// Equal values share the same level. All equal -> no colors.
  Map<String, _Level> _rankLevels(
    List<Property> props,
    double Function(Property) value, {
    required bool higherIsBetter,
  }) {
    final distinct = props.map(value).toSet().toList()
      ..sort((a, b) => higherIsBetter ? b.compareTo(a) : a.compareTo(b));
    if (distinct.length < 2) return const {};
    final palette = switch (distinct.length) {
      2 => [_Level.green, _Level.red],
      3 => [_Level.green, _Level.yellow, _Level.red],
      _ => [_Level.green, _Level.yellow, _Level.orange, _Level.red],
    };
    return {
      for (final p in props)
        p.propertyId:
            palette[math.min(distinct.indexOf(value(p)), palette.length - 1)],
    };
  }

  @override
  Widget build(BuildContext context) {
    final props = _properties;
    return Scaffold(
      body: SafeArea(
        child: props == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brown),
              )
            : _buildContent(props),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.explore),
    );
  }

  Widget _buildContent(List<Property> props) {
    final cheapest = _bestIds(props, (p) => p.rentPrice, higherIsBetter: false);
    final largest = _bestIds(props, (p) => p.areaSqm, higherIsBetter: true);
    final hasScores = widget.matchScores.isNotEmpty;
    final bestScore = hasScores
        ? _bestIds(
            props,
            (p) => (_scoreOf(p) ?? -1).toDouble(),
            higherIsBetter: true,
          )
        : <String>{};

    // all rows: label, text per property, and (for comparable rows)
    // a color per property from best (green) to worst (red)
    final rows = <_CompareRow>[
      _CompareRow(
        'سعر الإيجار (سنوياً)',
        (p) => '${formatNumber(p.rentPrice)} ر.س',
        _rankLevels(props, (p) => p.rentPrice, higherIsBetter: false),
      ),
      _CompareRow(
        'المساحة',
        (p) => formatArea(p.areaSqm),
        _rankLevels(props, (p) => p.areaSqm, higherIsBetter: true),
      ),
      _CompareRow('الحي', (p) => p.district, const {}),
      _CompareRow('نوع العقار', (p) => p.typeLabel, const {}),
      _CompareRow('نوع النشاط', (p) => p.activityType ?? '—', const {}),
      _CompareRow(
        'المواقف',
        (p) => p.hasParking == true ? 'متوفرة' : 'غير متوفرة',
        _rankLevels(
          props,
          (p) => p.hasParking == true ? 1 : 0,
          higherIsBetter: true,
        ),
      ),
      if (hasScores)
        _CompareRow(
          'درجة الملاءمة',
          (p) {
            final s = _scoreOf(p);
            return s == null ? '—' : '$s%';
          },
          _rankLevels(
            props,
            (p) => (_scoreOf(p) ?? -1).toDouble(),
            higherIsBetter: true,
          ),
        ),
    ];

    // "show differences only": hide rows where every property is the same
    final visibleRows = _onlyDifferences
        ? rows.where((r) => props.map(r.valueOf).toSet().length > 1).toList()
        : rows;

    // Recommended = most "best" cells; tie -> cheaper rent
    Property winner = props.first;
    var winnerPoints = -1;
    for (final p in props) {
      final points = [
        cheapest,
        largest,
        bestScore,
      ].where((set) => set.contains(p.propertyId)).length;
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
        const SizedBox(height: 14),
        _buildDifferencesSwitch(),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            // 2 properties fill the screen; 3-4 scroll sideways
            final columnWidth = math.max(
              150.0,
              (constraints.maxWidth - 12 * (props.length - 1)) / props.length,
            );
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardsRow(props, columnWidth),
                  const SizedBox(height: 10),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'من الأفضل إلى الأقل:',
                        style: TextStyle(fontSize: 14, color: AppColors.hint),
                      ),
                      _LegendDot(_Level.green, 'الأفضل'),
                      _LegendDot(_Level.yellow, 'جيد'),
                      _LegendDot(_Level.orange, 'مقبول'),
                      _LegendDot(_Level.red, 'الأقل'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (visibleRows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'لا توجد فروقات بين العقارات المختارة.',
                        style: TextStyle(fontSize: 15, color: AppColors.hint),
                      ),
                    ),
                  for (final row in visibleRows)
                    _buildRow(row, props, columnWidth),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        _buildRecommended(winner, reasons),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: AppColors.brown, size: 20),
                SizedBox(width: 4),
                Text(
                  'المحفوظات',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.brown,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'مقارنة العقارات',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.brownDark,
          ),
        ),
      ],
    );
  }

  /// "إظهار الفروقات فقط" switch.
  Widget _buildDifferencesSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows_rounded, color: AppColors.brown),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'إظهار الفروقات فقط',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.brownDark,
              ),
            ),
          ),
          Switch(
            value: _onlyDifferences,
            activeTrackColor: AppColors.brown,
            onChanged: (v) => setState(() => _onlyDifferences = v),
          ),
        ],
      ),
    );
  }

  /// Top: one card per property (photo, title, price). Tap -> details.
  Widget _buildCardsRow(List<Property> props, double width) {
    final canRemove = props.length > 2; // keep at least 2 to compare
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < props.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          SizedBox(
            width: width,
            child: _PropertyCard(
              property: props[i],
              onTap: () => _openDetails(props[i]),
              onRemove: canRemove ? () => _remove(props[i]) : null,
            ),
          ),
        ],
      ],
    );
  }

  /// One attribute: its name, then the value of each property under it.
  Widget _buildRow(_CompareRow row, List<Property> props, double width) {
    final totalWidth = width * props.length + 12 * (props.length - 1);
    return Container(
      width: totalWidth,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < props.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                _ValueCell(
                  width: width,
                  text: row.valueOf(props[i]),
                  level: row.levels[props[i].propertyId],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Dark green "العقار المرشح" box. Tap -> details.
  Widget _buildRecommended(Property winner, List<String> reasons) {
    return Material(
      color: _greenDark,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openDetails(winner),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'العقار المرشح',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      winner.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reasons.isEmpty
                          ? 'الأفضل توازناً بين السعر والمساحة.'
                          : '${reasons.join('، ')}.',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// One attribute row as plain data.
class _CompareRow {
  final String label;
  final String Function(Property) valueOf;
  final Map<String, _Level> levels; // empty = not comparable (no colors)
  const _CompareRow(this.label, this.valueOf, this.levels);
}

/// Property card at the top of a column: photo, title, price, remove (✕).
class _PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onRemove; // null = can't remove (only 2 left)

  const _PropertyCard({
    required this.property,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: PropertyImage(path: property.coverImage),
                ),
                if (onRemove != null)
                  PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'إزالة من المقارنة',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        onPressed: onRemove,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // always the height of 2 lines, so all cards are equal
                  SizedBox(
                    height: 46,
                    child: Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brown,
                        ),
                      ),
                      Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: AppColors.brown,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Color levels from best to worst.
enum _Level {
  green(Color(0xFFE3F3E6), Color(0xFF1F5A3A), Icons.check_circle),
  yellow(Color(0xFFFFF4CC), Color(0xFF7A5C00), Icons.thumb_up_alt_outlined),
  orange(Color(0xFFFDE6D2), Color(0xFF9A4A0B), Icons.remove_circle_outline),
  red(Color(0xFFFBE2DE), Color(0xFFA8342A), Icons.arrow_downward_rounded);

  final Color background;
  final Color foreground; // text, border and icon
  final IconData icon; // so color is not the only signal
  const _Level(this.background, this.foreground, this.icon);
}

/// One value, colored by its level (or plain white if not comparable).
class _ValueCell extends StatelessWidget {
  final double width;
  final String text;
  final _Level? level;

  const _ValueCell({
    required this.width,
    required this.text,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final l = level;
    // NOT a box with a border (that looks like a text field):
    // ranked values are a small colored pill that fits the text,
    // the others are plain text
    return SizedBox(
      width: width,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: l == null ? 0 : 12,
            vertical: 8,
          ),
          decoration: l == null
              ? null
              : BoxDecoration(
                  color: l.background,
                  borderRadius: BorderRadius.circular(20),
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (l != null) ...[
                Icon(l.icon, size: 17, color: l.foreground),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: l == null ? FontWeight.w600 : FontWeight.w800,
                    color: l?.foreground ?? AppColors.brownDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small colored dot + word for the legend.
class _LegendDot extends StatelessWidget {
  final _Level level;
  final String label;
  const _LegendDot(this.level, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(level.icon, size: 16, color: level.foreground),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: level.foreground,
          ),
        ),
      ],
    );
  }
}
