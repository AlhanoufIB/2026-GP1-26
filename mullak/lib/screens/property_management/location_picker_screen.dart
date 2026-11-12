import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/app_bottom_nav.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _riyadh = LatLng(24.7136, 46.6753);
  late LatLng _center = widget.initial ?? _riyadh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حدّد موقع العقار'),
        backgroundColor: AppColors.background,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onPositionChanged: (pos, _) => _center = pos.center,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mullak_app',
              ),
            ],
          ),
          // الدبوس الثابت في المنتصف
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on,
                  size: 48, color: AppColors.danger),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: CustomButton(
              text: 'تأكيد الموقع',
              onPressed: () => Navigator.pop(context, _center),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(
  current: AppTab.myProperties,
),
    );
  }
}