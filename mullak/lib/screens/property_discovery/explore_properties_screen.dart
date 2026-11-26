import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../repositories/property_repository.dart';
import '../../repositories/saved_properties_repository.dart';
import '../../theme/app_colors.dart';
import 'utils/explore_filter.dart';
import 'widgets/discovery_property_card.dart';
import 'property_details_screen.dart';
import 'saved_properties_screen.dart';
import 'business_info_screen.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/primary_button.dart';
import 'utils/discovery_formatters.dart';

/// "استكشاف العقارات" — lets a business owner browse available properties.

class ExplorePropertiesScreen extends StatefulWidget {
  const ExplorePropertiesScreen({super.key});

  @override
  State<ExplorePropertiesScreen> createState() =>
      _ExplorePropertiesScreenState();
}

class _ExplorePropertiesScreenState extends State<ExplorePropertiesScreen> {
  final _repository = PropertyRepository.instance;

  /// The properties being loaded. FutureBuilder rebuilds when it completes.
  late Future<List<Property>> _propertiesFuture;

  /// Current chip selection. Starts with nothing selected ("الكل").
  ExploreFilter _filter = const ExploreFilter();

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _repository.getAvailableProperties();
    // load this user's saved list, so bookmarks show correctly everywhere
    SavedPropertiesRepository.instance.refresh();
  }

  /// Load the list again (pull-to-refresh and the retry button).
  Future<void> _reload() async {
    final future = _repository.getAvailableProperties();
    setState(() => _propertiesFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brown,
          onRefresh: _reload,
          child: FutureBuilder<List<Property>>(
            future: _propertiesFuture,
            builder: (context, snapshot) {
              return ListView(
                // always scrollable, so pull-to-refresh works on short lists
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildSmartBanner(),
                  const SizedBox(height: 20),
                  _buildFilterBar(snapshot.data ?? const []),
                  const SizedBox(height: 16),
                  ..._buildResults(snapshot),
                ],
              );
            },
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const AppBottomNav(current: AppTab.explore),
    );
  }

  /// Title on the right, saved-properties button on the left (RTL).
  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'استكشاف العقارات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark,
            ),
          ),
        ),
        Material(
          color: AppColors.gradientStart,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavedPropertiesScreen()),
            ),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.bookmark_border, color: AppColors.brown),
            ),
          ),
        ),
      ],
    );
  }

  /// The brown "ترشيحات ذكية لنشاطك" card that leads to the business form.
  Widget _buildSmartBanner() {
    return Material(
      color: AppColors.brown,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BusinessInfoScreen())),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ترشيحات ذكية لنشاطك',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'أخبرنا عن نشاطك ونرتّب لك أنسب العقارات',
                      style: TextStyle(fontSize: 12.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  /// One simple "تصفية" button (+ "مسح" when filters are on).
  Widget _buildFilterBar(List<Property> all) {
    final n = _filter.activeCount;
    return Row(
      children: [
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: all.isEmpty ? null : () => _openFilterSheet(all),
            icon: const Icon(Icons.tune, size: 20),
            label: Text(n == 0 ? 'تصفية' : 'تصفية ($n)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: n == 0 ? AppColors.brown : Colors.white,
              backgroundColor: n == 0 ? Colors.white : AppColors.brown,
              side: BorderSide(
                color: n == 0 ? AppColors.border : AppColors.brown,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (n > 0) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => setState(() => _filter = const ExploreFilter()),
            child: const Text(
              'مسح',
              style: TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// The filter sheet: type chips + budget range + space range.
  Future<void> _openFilterSheet(List<Property> all) async {
    final types = {for (final p in all) p.propertyType}.toList();

    // fixed slider ends; the very ends mean "no limit" (change them here only)
    const rentMin = 0.0;
    const rentMax = 500000.0; // SAR / year
    const areaMin = 0.0;
    const areaMax = 2000.0; // m²

    // start from the current filter (or the full range)
    String? type = _filter.type;
    var budget = RangeValues(
      (_filter.minBudget ?? rentMin).clamp(rentMin, rentMax).toDouble(),
      (_filter.maxBudget ?? rentMax).clamp(rentMin, rentMax).toDouble(),
    );
    var space = RangeValues(
      (_filter.minSpace ?? areaMin).clamp(areaMin, areaMax).toDouble(),
      (_filter.maxSpace ?? areaMax).clamp(areaMin, areaMax).toDouble(),
    );

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.brownDark,
        ),
      ),
    );

    // the text under each slider; the slider ends mean "no limit"
    String rangeLabel(RangeValues v, double min, double max, String unit) {
      final from = formatNumber(v.start.roundToDouble());
      final to = formatNumber(v.end.roundToDouble());
      final noMin = v.start <= min;
      final noMax = v.end >= max;
      if (noMin && noMax) return 'بلا حد أدنى — بلا حد أعلى';
      if (noMin) return 'بلا حد أدنى — إلى $to $unit';
      if (noMax) return 'من $from $unit — بلا حد أعلى';
      return 'من $from إلى $to $unit';
    }

    final result = await showModalBottomSheet<ExploreFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // StatefulBuilder lets the sliders and chips update inside the sheet
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'تصفية العقارات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brownDark,
                ),
              ),

              // --- property type ---
              sectionTitle('نوع العقار'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in types)
                    ChoiceChip(
                      label: Text(PropertyType.labelOf(t)),
                      selected: type == t,
                      showCheckmark: false,
                      onSelected: (_) =>
                          setSheet(() => type = type == t ? null : t),
                      selectedColor: AppColors.brown,
                      backgroundColor: AppColors.background,
                      side: const BorderSide(color: AppColors.border),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: type == t ? Colors.white : AppColors.brownDark,
                      ),
                    ),
                ],
              ),

              // --- budget range ---
              sectionTitle('الميزانية السنوية'),
              Text(
                rangeLabel(budget, rentMin, rentMax, 'ر.س'),
                style: const TextStyle(fontSize: 13.5, color: AppColors.hint),
              ),
              RangeSlider(
                values: budget,
                min: rentMin,
                max: rentMax,
                divisions: 50,
                activeColor: AppColors.brown,
                inactiveColor: AppColors.gradientStart,
                onChanged: (v) => setSheet(() => budget = v),
              ),

              // --- space range ---
              sectionTitle('المساحة'),
              Text(
                rangeLabel(space, areaMin, areaMax, 'م²'),
                style: const TextStyle(fontSize: 13.5, color: AppColors.hint),
              ),
              RangeSlider(
                values: space,
                min: areaMin,
                max: areaMax,
                divisions: 40,
                activeColor: AppColors.brown,
                inactiveColor: AppColors.gradientStart,
                onChanged: (v) => setSheet(() => space = v),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'تطبيق',
                      onPressed: () => Navigator.of(ctx).pop(
                        ExploreFilter(
                          type: type,
                          // a handle left at the end = no limit on that side
                          minBudget: budget.start > rentMin
                              ? budget.start
                              : null,
                          maxBudget: budget.end < rentMax ? budget.end : null,
                          minSpace: space.start > areaMin ? space.start : null,
                          maxSpace: space.end < areaMax ? space.end : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(const ExploreFilter()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brown,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'مسح',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    // closed by swiping down -> null -> keep the old filter
    if (result != null && mounted) setState(() => _filter = result);
  }

  /// What appears under the chips, depending on the loading state.
  List<Widget> _buildResults(AsyncSnapshot<List<Property>> snapshot) {
    // 1) still loading
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

    // 2) loading failed
    if (snapshot.hasError) {
      return [
        _MessageBox(
          icon: Icons.wifi_off_rounded,
          text: 'تعذّر تحميل العقارات. تحقق من اتصالك وحاول مرة أخرى.',
          actionLabel: 'إعادة المحاولة',
          onAction: _reload,
        ),
      ];
    }

    // 3) loaded: apply the chips
    final properties = _filter.apply(snapshot.data ?? const []);
    if (properties.isEmpty) {
      // no filter chosen -> there are simply no properties yet
      if (_filter.isAll) {
        return const [
          _MessageBox(
            icon: Icons.storefront_outlined,
            text: 'لا توجد عقارات متاحة حالياً.\nتُضاف عقارات جديدة باستمرار.',
          ),
        ];
      }
      // the filter is hiding everything -> offer to clear it
      return [
        _MessageBox(
          icon: Icons.search_off_rounded,
          text: 'لا توجد عقارات تطابق اختيارك حالياً.',
          actionLabel: 'مسح الفلاتر',
          onAction: () => setState(() => _filter = const ExploreFilter()),
        ),
      ];
    }

    return [
      for (final property in properties)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DiscoveryPropertyCard(
            property: property,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PropertyDetailsScreen(property: property),
                ),
              );
            },
          ),
        ),
    ];
  }
}

/// Used for the empty state and the error state.
class _MessageBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageBox({
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
