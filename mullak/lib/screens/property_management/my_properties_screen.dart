import 'package:flutter/material.dart';
import '../../models/property_myProperty.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/property_card.dart';
import 'delete_property_dialog.dart';
import 'property_form_screen.dart';
import '../../widgets/app_bottom_nav.dart';
import '../map/map_screen.dart';
import '../authentication/account_screen.dart';
import '../property_discovery/explore_properties_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  // بيانات تجريبية، لاحقاً تجي من الـ API
  final List<property_myProperty> _properties = [
    const property_myProperty(
      id: 10482,
      type: 'محل تجاري بالدور الأرضي',
      area: 85,
      location: 'العليا',
      annualRent: 78000,
    ),
    const property_myProperty(
      id: 10533,
      type: 'مكتب بدور كامل',
      area: 140,
      location: 'حطين',
      annualRent: 120000,
    ),
  ];

  String? _banner;

  void _showBanner(String text) {
    setState(() => _banner = text);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _banner == text) setState(() => _banner = null);
    });
  }

  Future<void> _addProperty() async {
    final result = await Navigator.push<property_myProperty>(
      context,
      MaterialPageRoute(builder: (_) => const PropertyFormScreen()),
    );
    if (result == null) return;
    setState(() => _properties.insert(0, result));
    _showBanner('تم إضافة العقار بنجاح');
  }

  Future<void> _editProperty(property_myProperty property) async {
    final result = await Navigator.push<property_myProperty>(
      context,
      MaterialPageRoute(builder: (_) => PropertyFormScreen(property: property)),
    );
    if (result == null) return;
    setState(() {
      final i = _properties.indexWhere((p) => p.id == property.id);
      if (i != -1) _properties[i] = result;
    });
    _showBanner('تم حفظ التعديلات بنجاح');
  }

  Future<void> _deleteProperty(property_myProperty property) async {
    final confirmed = await showDeletePropertyDialog(context);
    if (!confirmed) return;
    setState(() => _properties.removeWhere((p) => p.id == property.id));
    _showBanner('تم حذف العقار بنجاح');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'عقاراتي',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              if (_banner != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.successText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _banner!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.successText,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _properties.isEmpty
                    ? const Center(
                        child: Text(
                          'ما عندك عقارات بعد',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _properties.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final p = _properties[i];
                          return PropertyCard(
                            property: p,
                            onEdit: () => _editProperty(p),
                            onDelete: () => _deleteProperty(p),
                          );
                        },
                      ),
              ),
              CustomButton(text: 'إضافة عقار +', onPressed: _addProperty),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.myProperties,
        onTabSelected: (tab) {
          if (tab == AppTab.explore) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const ExplorePropertiesScreen(),
              ),
            );
          } else if (tab == AppTab.account) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            );
          } else if (tab == AppTab.map) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MapScreen()),
            );
          }
        },
      ),
    );
  }
}
