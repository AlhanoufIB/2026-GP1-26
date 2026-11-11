import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../repositories/property_repository.dart';
import '../../theme/app_colors.dart';
import 'utils/explore_filter.dart';
import 'widgets/discovery_property_card.dart';
import 'property_details_screen.dart';
import 'saved_properties_screen.dart';
import 'business_info_screen.dart';
import '../property_management/my_properties_screen.dart';
import '../authentication/account_screen.dart';
import '../../widgets/app_bottom_nav.dart';
import '../map/map_screen.dart';


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
                  _buildChips(),
                  const SizedBox(height: 16),
                                   ..._buildResults(snapshot),
                ],
              );
            },
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: AppBottomNav(
        current: AppTab.explore,
        onTabSelected: (tab) {
          if (tab == AppTab.myProperties) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MyPropertiesScreen(),
              ),
            );
          } else if (tab == AppTab.account) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const AccountScreen(),
              ),
            );
          } else if (tab == AppTab.map) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MapScreen(),
              ),
            );
          }
        },
      ),
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

  /// The horizontal row of filter chips.
  /// "أراضٍ" is left out until the team adds land to the property types.
  Widget _buildChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'الكل',
            selected: _filter.isAll,
            onTap: () => setState(() => _filter = const ExploreFilter()),
          ),
          _FilterChip(
            label: 'محلات',
            selected: _filter.type == PropertyType.shop,
            onTap: () =>
                setState(() => _filter = _filter.toggleType(PropertyType.shop)),
          ),
          _FilterChip(
            label: 'مكاتب',
            selected: _filter.type == PropertyType.office,
            onTap: () => setState(
              () => _filter = _filter.toggleType(PropertyType.office),
            ),
          ),
          _FilterChip(
            label: 'أقل من 80 م²',
            selected: _filter.onlySmall,
            onTap: () => setState(() => _filter = _filter.toggleSmall()),
          ),
        ],
      ),
    );
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
      return const [
        _MessageBox(
          icon: Icons.search_off_rounded,
          text: 'لا توجد عقارات تطابق اختيارك حالياً.',
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

/// One rounded chip. Filled brown when selected, outlined when not.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.brown : AppColors.background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.brown : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.brownDark,
            ),
          ),
        ),
      ),
    );
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
