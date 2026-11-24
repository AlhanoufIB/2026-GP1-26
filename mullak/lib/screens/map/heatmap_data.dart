import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:mullak/dataconnect_generated/generated.dart';

class HeatPoint {
  final double lat, lng;
  final bool fromUser;
  final String? district, category;
  final double? rentPerM2;
  const HeatPoint({
    required this.lat,
    required this.lng,
    required this.fromUser,
    this.district,
    this.category,
    this.rentPerM2,
  });
}

Future<List<HeatPoint>> loadDatasetPoints() async {
  final raw = await rootBundle.loadString('assets/data/heatmap_points.json');
  final points = (jsonDecode(raw)['points'] as List);
  return points
      .map((p) => HeatPoint(
            lat: (p['lat'] as num).toDouble(),
            lng: (p['lng'] as num).toDouble(),
            fromUser: false,
            district: p['district'] as String?,
            category: p['category'] as String?,
            rentPerM2: (p['commercial_rent_per_m2'] as num?)?.toDouble(),
          ))
      .toList();
}

Future<List<HeatPoint>> loadUserProperties() async {
  final result =
      await MullakConnector.instance.listAvailableProperties().execute();
  return result.data.properties
      .map((p) => HeatPoint(
            lat: p.latitude,
            lng: p.longitude,
            fromUser: true,
            district: p.district,
            category: p.propertyType,
          ))
      .toList();
}

Future<List<HeatPoint>> loadAllHeatPoints() async {
  final results = await Future.wait([
    loadDatasetPoints(),
    loadUserProperties().catchError((_) => <HeatPoint>[]),
  ]);
  return [...results[0], ...results[1]];
}

class HeatCell {
  final LatLng center;
  final int count;
  const HeatCell(this.center, this.count);
}

List<HeatCell> buildCells(List<HeatPoint> points, {double cellDeg = 0.005}) {
  final groups = <String, List<HeatPoint>>{};
  for (final p in points) {
    final key = '${(p.lat / cellDeg).floor()}_${(p.lng / cellDeg).floor()}';
    groups.putIfAbsent(key, () => []).add(p);
  }
  return groups.values.map((g) {
    final lat = g.map((p) => p.lat).reduce((a, b) => a + b) / g.length;
    final lng = g.map((p) => p.lng).reduce((a, b) => a + b) / g.length;
    return HeatCell(LatLng(lat, lng), g.length);
  }).toList();
}

Color Function(int) densityColors(List<HeatCell> cells) {
  final counts = cells.map((c) => c.count).toList()..sort();
  if (counts.isEmpty) return (_) => Colors.yellow;
  final low = counts[(counts.length * 0.33).floor()];
  final high = counts[(counts.length * 0.66).floor()];
  return (n) => n > high ? Colors.red : (n > low ? Colors.orange : Colors.yellow);
}