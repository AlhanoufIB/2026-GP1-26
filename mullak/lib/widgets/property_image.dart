import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PropertyImage extends StatelessWidget {
  final String? path;
  final double size;
  final double radius;

  const PropertyImage({
    super.key,
    required this.path,
    this.size = 72,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: AppColors.beigeSoft,
        child: path == null
            ? const Icon(Icons.storefront_outlined,
                color: AppColors.primary, size: 30)
            : Image.file(File(path!), fit: BoxFit.cover),
      ),
    );
  }
}