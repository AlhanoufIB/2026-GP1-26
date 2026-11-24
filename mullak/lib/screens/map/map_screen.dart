import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../dataconnect_generated/generated.dart';
import '../../models/property.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';

import '../property_discovery/property_details_screen.dart';
import '../property_discovery/utils/discovery_formatters.dart';
import '../notifications/notifications_screen.dart';

import 'map_property_service.dart';
import 'widgets/map_filter_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final MapPropertyService _mapPropertyService =
      MapPropertyService();

  static const LatLng _riyadhCenter =
      LatLng(24.7500, 46.6700);

  // Density legend colors.
  // Actual neighborhood density data will be linked later.
  static const Color _highDensity = Color(0xFFD95B59);
  static const Color _mediumDensity = Color(0xFFF0A44A);
  static const Color _lowDensity = Color(0xFFF0D76C);

  MapFilterSelection _filters = const MapFilterSelection();

  List<ListAvailablePropertiesProperties> _allProperties = [];

  ListAvailablePropertiesProperties? _selectedProperty;

  bool _isLoading = true;
  bool _isOpeningDetails = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadMapProperties();
  }

  // Fetch real available properties from Firebase.
  Future<void> _loadMapProperties() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final properties =
          await _mapPropertyService.getAvailableProperties();

      if (!mounted) return;

      setState(() {
        _allProperties = properties;
        _isLoading = false;

        // Keep selection only if the property still exists.
        if (_selectedProperty != null) {
          final selectedId = _selectedProperty!.id;
          _selectedProperty = null;

          for (final property in properties) {
            if (property.id == selectedId) {
              _selectedProperty = property;
              break;
            }
          }

          if (_selectedProperty != null &&
              !_matchesFilters(_selectedProperty!)) {
            _selectedProperty = null;
          }
        }
      });

      debugPrint(
        'MAP DATABASE: Loaded ${properties.length} properties',
      );
    } catch (error, stackTrace) {
      debugPrint('MAP DATABASE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'تعذّر تحميل العقارات من قاعدة البيانات';
        _allProperties = [];
        _selectedProperty = null;
      });
    }
  }

  // Apply selected filters to Firebase query results.
  bool _matchesFilters(
    ListAvailablePropertiesProperties property,
  ) {
    // Property type filter.
    if (_filters.propertyType != null &&
        property.propertyType != _filters.propertyType) {
      return false;
    }

    // Dynamic price range.
    // The default upper bound is infinity, meaning no price limit.
    final price = _filters.priceRange;

    if (property.rentPrice < price.start ||
        property.rentPrice > price.end) {
      return false;
    }

    // Area filter.
    switch (_filters.areaRange) {
      case 'under50':
        return property.areaSqm < 50;

      case '50to100':
        return property.areaSqm >= 50 &&
            property.areaSqm <= 100;

      case '100to200':
        return property.areaSqm > 100 &&
            property.areaSqm <= 200;

      case 'over200':
        return property.areaSqm > 200;

      default:
        return true;
    }
  }

  // Properties matching the currently selected filters.
  List<ListAvailablePropertiesProperties>
      get _visibleProperties {
    return _allProperties.where(_matchesFilters).toList();
  }

  String _formatPrice(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  // Open map filters using the complete Firebase property list.
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
            availableProperties: _allProperties,
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

  // Open notifications screen.
  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  // Select a real property marker.
  void _selectProperty(
    ListAvailablePropertiesProperties property,
  ) {
    setState(() {
      _selectedProperty = property;
    });

    _mapController.move(
      LatLng(property.latitude, property.longitude),
      14,
    );
  }

  // Reset map position.
  void _resetMap() {
    setState(() {
      _selectedProperty = null;
    });

    _mapController.move(_riyadhCenter, 11);
  }

  // Fetch full property data only when requested.
  Future<void> _showPropertyDetails(
    ListAvailablePropertiesProperties listing,
  ) async {
    if (_isOpeningDetails) return;

    setState(() {
      _isOpeningDetails = true;
    });

    try {
      final property =
          await _mapPropertyService.getPropertyById(
        listing.id,
      );

      if (!mounted) return;

      if (property == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذا العقار لم يعد متاحًا'),
          ),
        );

        await _loadMapProperties();
        return;
      }

      _showPropertyPreview(property);
    } catch (error, stackTrace) {
      debugPrint('MAP PROPERTY DETAILS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر تحميل تفاصيل العقار'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningDetails = false;
        });
      }
    }
  }

  // Navigate to the existing property details screen.
  void _openFullPropertyDetails(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsScreen(
          property: property,
        ),
      ),
    );
  }

  // Display Firebase Storage images.
  Widget _propertyImage(
    String? imageUrl, {
    required double height,
    double? width,
  }) {
    final placeholder = Container(
      height: height,
      width: width,
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_outlined,
        size: 38,
        color: AppColors.brown,
      ),
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder;
    }

    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder;
      },
    );
  }

  // Preview sheet with complete database details.
  void _showPropertyPreview(Property property) {
    final parking = property.hasParking == null
        ? 'غير محدد'
        : property.hasParking!
            ? 'متوفرة'
            : 'غير متوفرة';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20, 0, 20, 24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Property image.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _propertyImage(
                      property.coverImage,
                      height: 180,
                      width: double.infinity,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Property title.
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brownDark,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // City, district and property ID.
                  Text(
                    '${property.city} · '
                    '${property.district}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.hint,
                    ),
                  ),

                  // Address, when provided.
                  if (property.address != null &&
                      property.address!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      property.address!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hint,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Annual rent.
                  Text(
                    formatYearlyRent(property.rentPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brown,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Area, type and parking.
                  Row(
                    children: [
                      Expanded(
                        child: _infoBox(
                          value: formatArea(property.areaSqm),
                          label: 'المساحة',
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _infoBox(
                          value: property.typeLabel,
                          label: 'النوع',
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _infoBox(
                          value: parking,
                          label: 'المواقف',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Property description.
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 110,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'وصف العقار',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brownDark,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          property.description
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? property.description!
                              : 'لا يوجد وصف',
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: AppColors.brownDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Full property details button.
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _openFullPropertyDetails(property);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'عرض تفاصيل العقار',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.chevron_left,
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Information box.
  Widget _infoBox({
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.hint,
            ),
          ),
        ],
      ),
    );
  }

  // Density legend.
  // Display only: no density colors are applied to markers yet.
  Widget _densityLegend() {
    Widget legendItem(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.brownDark,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
         

          legendItem(_highDensity, 'كثافة عالية'),

          const SizedBox(height: 8),

          legendItem(_mediumDensity, 'كثافة متوسطة'),

          const SizedBox(height: 8),

          legendItem(_lowDensity, 'كثافة منخفضة'),
        ],
      ),
    );
  }

  // Notification button.
  Widget _notificationButton() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: NotificationsScreen.unreadIds,
      builder: (context, unread, _) {
        return Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _openNotifications,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.brown,
                    size: 26,
                  ),

                  if (unread.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD94D3D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Property marker.
  // Density-based marker coloring will be added later.
  Widget _propertyMarker(
    ListAvailablePropertiesProperties property,
  ) {
    final selected =
        _selectedProperty?.id == property.id;

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

  // Small property card on the map.
  Widget _propertyCard(
    ListAvailablePropertiesProperties property,
  ) {
    final imageUrl = property.coverImage.isEmpty
        ? null
        : property.coverImage.first.imageUrl;

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
                  '${property.areaSqm} م²  •  '
                  '${property.district}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.hint,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${_formatPrice(property.rentPrice)}'
                  ' ر.س / سنويًا',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),

                const SizedBox(height: 7),

                // Fetch full details when tapped.
                InkWell(
                  onTap: _isOpeningDetails
                      ? null
                      : () => _showPropertyDetails(property),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isOpeningDetails)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.only(
                            bottom: 2,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.brown,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: const Text(
                            'التفاصيل',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.brown,
                            ),
                          ),
                        ),

                        const SizedBox(width: 3),

                        const Icon(
                          Icons.chevron_left,
                          size: 15,
                          color: AppColors.brown,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Firebase image or placeholder.
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _propertyImage(
              imageUrl,
              width: 90,
              height: 100,
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

  // Loading, error and empty-state message.
  Widget _messagePanel(
    String message, {
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.brownDark,
            ),
          ),

          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
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

                // Real Firebase property markers.
                // No density circles or colors are added here.
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

            // Notifications.
            Positioned(
              top: 16,
              left: 12,
              child: _notificationButton(),
            ),

            // Density legend.
            // Actual density data will be connected later.
            Positioned(
              top: 80,
              left: 12,
              child: _densityLegend(),
            ),

            // Filters.
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

            // Recenter map.
            Positioned(
              right: 16,
              top: 80,
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius:
                    BorderRadius.circular(12),
                child: IconButton(
                  tooltip: 'العودة لوسط الرياض',
                  onPressed: _resetMap,
                  icon: const Icon(
                    Icons.my_location,
                    color: AppColors.brown,
                  ),
                ),
              ),
            ),

            // Refresh properties.
            Positioned(
              right: 16,
              top: 136,
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius:
                    BorderRadius.circular(12),
                child: IconButton(
                  tooltip: 'تحديث العقارات',
                  onPressed:
                      _isLoading ? null : _loadMapProperties,
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.brown,
                  ),
                ),
              ),
            ),

            // Selected property card.
            if (_selectedProperty != null &&
                !_isLoading &&
                _loadError == null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 14,
                child: _propertyCard(
                  _selectedProperty!,
                ),
              ),

            // Loading state.
            if (_isLoading)
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: _messagePanel(
                  'جاري تحميل العقارات...',
                ),
              )

            // Database error.
            else if (_loadError != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: _messagePanel(
                  _loadError!,
                  onRetry: _loadMapProperties,
                ),
              )

            // No properties or no filter matches.
            else if (properties.isEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: _messagePanel(
                  _allProperties.isEmpty
                      ? 'لا توجد عقارات متاحة حاليًا'
                      : 'لا توجد عقارات مطابقة للتصفية',
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