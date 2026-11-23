import 'package:flutter/material.dart';

import '../../../dataconnect_generated/generated.dart';
import '../../../models/property.dart';
import '../../../theme/app_colors.dart';

class MapFilterSelection {
  final String? propertyType;
  final String? areaRange;
  final RangeValues priceRange;

  const MapFilterSelection({
    this.propertyType,
    this.areaRange,
    this.priceRange = const RangeValues(0, double.infinity),
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

  // All available properties fetched from Firebase Data Connect.
  // Pass the complete unfiltered list from the map screen.
  final List<ListAvailablePropertiesProperties> availableProperties;

  const MapFilterSheet({
    super.key,
    required this.initialFilters,
    required this.availableProperties,
  });

  @override
  State<MapFilterSheet> createState() =>
      _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late String? _selectedType;
  late String? _selectedArea;
  late RangeValues _priceRange;

  late double _maxPrice;
  late List<String> _availableTypes;
  late Set<String> _availableAreaRanges;

  static const Map<String, String> _typeLabels = {
    PropertyType.shop: 'محل تجاري',
    PropertyType.office: 'مكتب',
    PropertyType.kiosk: 'كشك',
  };

  static const Map<String, String> _areaLabels = {
    'under50': 'أقل من 50',
    '50to100': '50–100',
    '100to200': '100–200',
    'over200': 'أكثر من 200',
  };

  @override
  void initState() {
    super.initState();

    _prepareFilterData();

    final initial = widget.initialFilters;

    _selectedType = _availableTypes.contains(initial.propertyType)
        ? initial.propertyType
        : null;

    _selectedArea =
        _availableAreaRanges.contains(initial.areaRange)
            ? initial.areaRange
            : null;

    _priceRange = _normalizePriceRange(initial.priceRange);
  }

  void _prepareFilterData() {
    final properties = widget.availableProperties;

    // Highest annual rent in the available properties.
    // The minimum is always zero.
    _maxPrice = 0;

    for (final property in properties) {
      final price = property.rentPrice.toDouble();

      if (price > _maxPrice) {
        _maxPrice = price;
      }
    }

    // Only property types that actually exist in Firebase.
    _availableTypes = properties
        .map((property) => property.propertyType)
        .toSet()
        .toList()
      ..sort();

    // Only area categories containing available properties.
    _availableAreaRanges = {};

    for (final property in properties) {
      final area = property.areaSqm;

      if (area < 50) {
        _availableAreaRanges.add('under50');
      } else if (area <= 100) {
        _availableAreaRanges.add('50to100');
      } else if (area <= 200) {
        _availableAreaRanges.add('100to200');
      } else {
        _availableAreaRanges.add('over200');
      }
    }
  }

  RangeValues _normalizePriceRange(RangeValues range) {
    if (_maxPrice <= 0) {
      return const RangeValues(0, 0);
    }

    final start = range.start
        .clamp(0.0, _maxPrice)
        .toDouble();

    final end = range.end.isInfinite
        ? _maxPrice
        : range.end.clamp(0.0, _maxPrice).toDouble();

    return RangeValues(
      start <= end ? start : end,
      end,
    );
  }

  void _clearAll() {
    setState(() {
      _selectedType = null;
      _selectedArea = null;
      _priceRange = RangeValues(0, _maxPrice);
    });
  }

  void _applyFilters() {
    // Infinity means no upper price restriction.
    // This allows new, more expensive properties to be included
    // when the user has selected the entire price range.
    final isFullRange =
        _priceRange.start == 0 &&
        _priceRange.end == _maxPrice;

    Navigator.pop(
      context,
      MapFilterSelection(
        propertyType: _selectedType,
        areaRange: _selectedArea,
        priceRange: isFullRange
            ? const RangeValues(0, double.infinity)
            : _priceRange,
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
    final hasProperties = widget.availableProperties.isNotEmpty;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      'أنواع العقارات المتاحة',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.hint,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (_availableTypes.isEmpty)
                      const Text(
                        'لا توجد أنواع عقارات متاحة حاليًا',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.hint,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 9,
                        runSpacing: 10,
                        children: _availableTypes.map((type) {
                          return _typeChip(
                            _typeLabels[type] ?? type,
                            type,
                          );
                        }).toList(),
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

                    if (hasProperties && _maxPrice > 0) ...[
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
                          max: _maxPrice,
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
                    ] else ...[
                      const Text(
                        'لا توجد أسعار إيجار متاحة لتحديد النطاق',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.hint,
                        ),
                      ),
                    ],

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

                    if (_availableAreaRanges.isEmpty)
                      const Text(
                        'لا توجد مساحات عقارات متاحة حاليًا',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.hint,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 9,
                        runSpacing: 10,
                        children: _areaLabels.entries
                            .where(
                              (entry) => _availableAreaRanges
                                  .contains(entry.key),
                            )
                            .map(
                              (entry) => _areaChip(
                                entry.value,
                                entry.key,
                              ),
                            )
                            .toList(),
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