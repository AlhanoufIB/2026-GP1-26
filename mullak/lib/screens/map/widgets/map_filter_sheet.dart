import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../theme/app_colors.dart';

class MapFilterSelection {
  final String? propertyType;
  final String? areaRange;
  final RangeValues priceRange;

  const MapFilterSelection({
    this.propertyType,
    this.areaRange,
    this.priceRange = const RangeValues(0, 150000),
  });

  bool matches(Property property) {
    if (property.status != PropertyStatus.available) {
      return false;
    }

    if (propertyType != null &&
        property.propertyType != propertyType) {
      return false;
    }

    if (property.rentPrice < priceRange.start ||
        property.rentPrice > priceRange.end) {
      return false;
    }

    final area = property.areaSqm;

    switch (areaRange) {
      case 'under50':
        return area < 50;
      case '50to100':
        return area >= 50 && area <= 100;
      case '100to200':
        return area > 100 && area <= 200;
      case 'over200':
        return area > 200;
      default:
        return true;
    }
  }
}

class MapFilterSheet extends StatefulWidget {
  final MapFilterSelection initialFilters;

  const MapFilterSheet({
    super.key,
    required this.initialFilters,
  });

  @override
  State<MapFilterSheet> createState() =>
      _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late String? _selectedType;
  late String? _selectedArea;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilters.propertyType;
    _selectedArea = widget.initialFilters.areaRange;
    _priceRange = widget.initialFilters.priceRange;
  }

  void _clearAll() {
    setState(() {
      _selectedType = null;
      _selectedArea = null;
      _priceRange = const RangeValues(0, 150000);
    });
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      MapFilterSelection(
        propertyType: _selectedType,
        areaRange: _selectedArea,
        priceRange: _priceRange,
      ),
    );
  }

  String _price(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  Widget _optionChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.brown : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.brown
                : const Color(0xFFD6C9BC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : AppColors.brownDark,
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value) {
    return _optionChip(
      label: label,
      selected: _selectedType == value,
      onTap: () {
        setState(() {
          _selectedType =
              _selectedType == value ? null : value;
        });
      },
    );
  }

  Widget _areaChip(String label, String value) {
    return _optionChip(
      label: label,
      selected: _selectedArea == value,
      onTap: () {
        setState(() {
          _selectedArea =
              _selectedArea == value ? null : value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD7C4AC),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'تصفية الخريطة',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brownDark,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text(
                      'مسح الكل',
                      style: TextStyle(
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 24,
              color: Color(0xFFEDE5DC),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع النشاط',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brownDark,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'خيارات تجريبية حسب أنواع العقارات المتاحة',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.hint,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 9,
                      runSpacing: 10,
                      children: [
                        _typeChip(
                          'محل تجاري',
                          PropertyType.shop,
                        ),
                        _typeChip(
                          'مكتب',
                          PropertyType.office,
                        ),
                        _typeChip(
                          'كشك',
                          PropertyType.kiosk,
                        ),
                      ],
                    ),

                    const SizedBox(height: 38),

                    const Text(
                      'ميزانية الإيجار السنوية (ر.س)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brownDark,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.brown,
                        inactiveTrackColor:
                            const Color(0xFFE2D6C8),
                        thumbColor: Colors.white,
                        overlayColor:
                            AppColors.brown.withValues(
                          alpha: 0.12,
                        ),
                        rangeThumbShape:
                            const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 9,
                        ),
                      ),
                      child: RangeSlider(
                        min: 0,
                        max: 150000,
                        divisions: 30,
                        values: _priceRange,
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_price(_priceRange.start)} ر.س',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.brownDark,
                          ),
                        ),
                        Text(
                          '${_price(_priceRange.end)} ر.س',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.brownDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 38),

                    const Text(
                      'المساحة (م²)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brownDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 9,
                      runSpacing: 10,
                      children: [
                        _areaChip(
                          'أقل من 50',
                          'under50',
                        ),
                        _areaChip(
                          '50–100',
                          '50to100',
                        ),
                        _areaChip(
                          '100–200',
                          '100to200',
                        ),
                        _areaChip(
                          'أكثر من 200',
                          'over200',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                12,
                22,
                20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تطبيق التصفية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}