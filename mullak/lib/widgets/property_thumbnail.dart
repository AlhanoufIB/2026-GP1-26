import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// رابط (محفوظة في Firebase) أو مسار ملف (لسا ما انرفعت)
ImageProvider imageProviderFor(String path) => path.startsWith('http')
    ? NetworkImage(path)
    : FileImage(File(path)) as ImageProvider;

class PropertyThumbnail extends StatelessWidget {
  final String? path;
  final double size;
  final double radius;

  const PropertyThumbnail({
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
            : Image(
                image: imageProviderFor(path!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted),
              ),
      ),
    );
  }
}