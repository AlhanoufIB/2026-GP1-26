import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// What OpenStreetMap knows about the place under the map pin.
class PinAddress {
  /// Street name (e.g. "طريق الملك فهد"), or null if OSM has none.
  final String? street;

  /// Every area name OSM gives for the pin (suburb, neighbourhood, ...),
  /// used to check the pin is inside the chosen district.
  final List<String> areaNames;

  const PinAddress({this.street, this.areaNames = const []});
}

/// Reverse geocoding with OpenStreetMap Nominatim (free, no API key).
/// Usage policy: max ~1 request per second and an identifying User-Agent.
/// We only call it when the owner confirms a pin, so we stay far below that.
class ReverseGeocodeService {
  ReverseGeocodeService._();
  static final instance = ReverseGeocodeService._();

  /// Returns null if the lookup failed (no internet, timeout, server error).
  Future<PinAddress?> lookup(LatLng point) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': point.latitude.toStringAsFixed(6),
      'lon': point.longitude.toStringAsFixed(6),
      'zoom': '18', // street level
      'addressdetails': '1',
      'accept-language': 'ar',
    });
    try {
      final res = await http
          .get(
            uri,
            // Browsers don't allow setting User-Agent (they send their own).
            headers: kIsWeb
                ? const {}
                : const {'User-Agent': 'MullakApp/1.0 (KSU IT496 project)'},
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;

      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final addr = (body is Map ? body['address'] : null);
      if (addr is! Map) return const PinAddress();

      String? text(String key) {
        final v = addr[key];
        return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
      }

      return PinAddress(
        street: text('road') ?? text('pedestrian') ?? text('street'),
        areaNames: [
          for (final k in const [
            'suburb',
            'neighbourhood',
            'quarter',
            'city_district',
            'residential',
          ])
            if (text(k) != null) text(k)!,
        ],
      );
    } catch (e) {
      debugPrint('REVERSE GEOCODE ERROR: $e');
      return null;
    }
  }

  /// "حي النرجس" / "النرجس" / "النّرجس" -> "نرجس", so names written
  /// slightly differently still match.
  static String normalize(String s) {
    var t = s.trim();
    t = t.replaceAll(RegExp(r'[ً-ْـ]'), ''); // harakat, tatweel
    t = t.replaceAll(RegExp(r'^حي\s+'), '');
    t = t.replaceAll(RegExp('[أإآ]'), 'ا');
    t = t.replaceAll('ة', 'ه').replaceAll('ى', 'ي');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    t = t.split(' ').map((w) => w.startsWith('ال') && w.length > 3 ? w.substring(2) : w).join(' ');
    return t.toLowerCase();
  }

  /// true  = the pin is in [district]
  /// false = OSM says the pin is in a different area
  /// null  = can't tell (OSM gave no area name)
  static bool? isInDistrict(PinAddress a, String district) {
    if (a.areaNames.isEmpty) return null;
    final want = normalize(district);
    for (final name in a.areaNames) {
      final got = normalize(name);
      if (got == want || got.contains(want) || want.contains(got)) return true;
    }
    return false;
  }
}
