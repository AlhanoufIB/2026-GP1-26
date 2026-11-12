import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/sample_properties.dart';
import '../../models/property.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import 'widgets/map_filter_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _riyadhCenter =
      LatLng(24.7500, 46.6700);

  MapFilterSelection _filters =
      const MapFilterSelection();

  Property? _selectedProperty;

  // Temporary density colors for the Figma prototype.
  static const Color _highDensity =
      Color(0xFFD95B59);
  static const Color _mediumDensity =
      Color(0xFFF0A44A);
  static const Color _lowDensity =
      Color(0xFFF0D76C);

  List<Property> get _visibleProperties {
    return sampleProperties
        .where((property) => _filters.matches(property))
        .toList();
  }

  String _formatPrice(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  String _typeName(String type) {
    if (type == PropertyType.shop) return 'محل تجاري';
    if (type == PropertyType.office) return 'مكتب';
    if (type == PropertyType.kiosk) return 'كشك';
    return 'عقار تجاري';
  }

  // Multiple transparent circles create a soft,
  // illustrative density effect on the map.
  List<CircleMarker> _densitySpot(
    LatLng center,
    Color color,
    double radius,
  ) {
    return [
      CircleMarker(
        point: center,
        radius: radius,
        color: color.withValues(alpha: 0.07),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: center,
        radius: radius * 0.72,
        color: color.withValues(alpha: 0.12),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: center,
        radius: radius * 0.45,
        color: color.withValues(alpha: 0.20),
        borderStrokeWidth: 0,
      ),
      CircleMarker(
        point: center,
        radius: radius * 0.22,
        color: color.withValues(alpha: 0.15),
        borderStrokeWidth: 0,
      ),
    ];
  }

  List<CircleMarker> get _demoDensityCircles {
    return [
      ..._densitySpot(
        const LatLng(24.6936, 46.6853),
        _highDensity,
        105,
      ),
      ..._densitySpot(
        const LatLng(24.8070, 46.6100),
        _mediumDensity,
        100,
      ),
      ..._densitySpot(
        const LatLng(24.7650, 46.6050),
        _lowDensity,
        90,
      ),
      ..._densitySpot(
        const LatLng(24.8550, 46.6700),
        _lowDensity,
        85,
      ),
    ];
  }

  Future<void> _openFilters() async {
    final result =
        await showModalBottomSheet<MapFilterSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.76,
          child: MapFilterSheet(
            initialFilters: _filters,
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      _filters = result;
      _selectedProperty = null;
    });
  }

  void _selectProperty(Property property) {
    setState(() {
      _selectedProperty = property;
    });

    _mapController.move(
      LatLng(
        property.latitude,
        property.longitude,
      ),
      14,
    );
  }

  void _resetMap() {
    setState(() {
      _selectedProperty = null;
    });

    _mapController.move(_riyadhCenter, 11);
  }

  void _showPropertyDetails(Property property) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20, 0, 20, 30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (property.imageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: Image.asset(
                      property.imageUrls.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const SizedBox(
                        height: 100,
                        child: Center(
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 55,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brownDark,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '${property.district}، ${property.city}',
                ),

                const SizedBox(height: 10),

                Text(
                  'نوع العقار: ${_typeName(property.propertyType)}',
                ),

                const SizedBox(height: 10),

                Text(
                  'المساحة: ${property.areaSqm} م²',
                ),

                const SizedBox(height: 10),

                Text(
                  'الإيجار السنوي: ${_formatPrice(property.rentPrice)} ر.س',
                ),

                const SizedBox(height: 10),

                Text(
                  property.hasParking == true
                      ? 'تتوفر مواقف'
                      : 'المواقف غير مؤكدة',
                ),

                if (property.description != null &&
                    property.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(property.description!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _densityLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendRow('كثافة عالية', _highDensity),
          const SizedBox(height: 6),
          _legendRow('كثافة متوسطة', _mediumDensity),
          const SizedBox(height: 6),
          _legendRow('كثافة منخفضة', _lowDensity),
        ],
      ),
    );
  }

  Widget _legendRow(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(width: 7),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _propertyMarker(Property property) {
    final selected =
        _selectedProperty?.propertyId ==
            property.propertyId;

    return GestureDetector(
      onTap: () => _selectProperty(property),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          width: selected ? 24 : 19,
          height: selected ? 24 : 19,
          decoration: BoxDecoration(
            color: AppColors.brown,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _propertyCard(Property property) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brownDark,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${property.areaSqm} م²  •  ${property.district}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.hint,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${_formatPrice(property.rentPrice)} ر.س / سنويًا',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),

                const SizedBox(height: 7),

                InkWell(
                  onTap: () =>
                      _showPropertyDetails(property),
                  child: const Text(
                    'التفاصيل',
                    style: TextStyle(
                      fontSize: 12,
                      decoration:
                          TextDecoration.underline,
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          if (property.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                property.imageUrls.first,
                width: 90,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const SizedBox(
                  width: 90,
                  height: 100,
                  child: Icon(
                    Icons.storefront_outlined,
                    color: AppColors.brown,
                  ),
                ),
              ),
            ),

          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() {
                _selectedProperty = null;
              });
            },
            icon: const Icon(
              Icons.close,
              size: 17,
              color: AppColors.hint,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final properties = _visibleProperties;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _riyadhCenter,
                initialZoom: 11,
                minZoom: 5,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'sa.edu.ksu.mullak',
                ),

                // Illustrative density overlay.
                CircleLayer(
                  circles: _demoDensityCircles,
                ),

                MarkerLayer(
                  markers: properties.map((property) {
                    return Marker(
                      point: LatLng(
                        property.latitude,
                        property.longitude,
                      ),
                      width: 45,
                      height: 45,
                      child: _propertyMarker(property),
                    );
                  }).toList(),
                ),

                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),

            // Top-left density legend.
            Positioned(
              top: 16,
              left: 12,
              child: _densityLegend(),
            ),

            // Top-right filter icon.
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: AppColors.brown,
                elevation: 3,
                borderRadius:
                    BorderRadius.circular(12),
                child: InkWell(
                  onTap: _openFilters,
                  borderRadius:
                      BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),

            // Recenter the map.
            Positioned(
              right: 16,
              top: 80,
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius:
                    BorderRadius.circular(12),
                child: IconButton(
                  onPressed: _resetMap,
                  icon: const Icon(
                    Icons.my_location,
                    color: AppColors.brown,
                  ),
                ),
              ),
            ),

            // Property details card.
            if (_selectedProperty != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 14,
                child: _propertyCard(
                  _selectedProperty!,
                ),
              ),

            // Empty filter result.
            if (properties.isEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'لا توجد عقارات مطابقة للتصفية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.brownDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      bottomNavigationBar: const AppBottomNav(
  current: AppTab.map,
),
    );
  }
}