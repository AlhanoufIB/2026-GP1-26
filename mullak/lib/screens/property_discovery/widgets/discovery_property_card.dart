import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../theme/app_colors.dart';
import '../utils/discovery_formatters.dart';
import 'property_image.dart';

/// The big property card on the Explore page:
/// photo on top, then title, "85 م² · رقم العقار 10482", then the rent.
class DiscoveryPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const DiscoveryPropertyCard({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      // Clip.antiAlias cuts the photo to the card's rounded corners
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 145,
              child: PropertyImage(path: property.coverImage),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brownDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatArea(property.areaSqm)} · رقم العقار ${property.propertyId}',
                    style: const TextStyle(fontSize: 14, color: AppColors.hint),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatYearlyRent(property.rentPrice),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brown,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
