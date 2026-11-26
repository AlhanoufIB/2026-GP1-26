import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../repositories/saved_properties_repository.dart';
import '../../../theme/app_colors.dart';
import '../utils/discovery_formatters.dart';
import 'property_image.dart';

/// The big property card on the Explore page:
/// photo on top, then title, area and rent, with a save button
/// at the bottom left.
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end, // button at the bottom
                children: [
                  // text on the right (RTL start)
                  Expanded(
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
                          formatArea(property.areaSqm),
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.hint),
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
                  const SizedBox(width: 12),
                  // save button on the left (RTL end)
                  _SaveButton(property: property),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square bookmark button. Same saved list as the details page,
/// so saving here shows as saved everywhere.
class _SaveButton extends StatelessWidget {
  final Property property;

  const _SaveButton({required this.property});

  Future<void> _toggle(BuildContext context) async {
    final repo = SavedPropertiesRepository.instance;
    final messenger = ScaffoldMessenger.of(context); // grab it before await
    final wasSaved = repo.isSaved(property.propertyId);

    await repo.toggle(property.propertyId);

    // toggle() undoes itself if the database call failed
    final failed = repo.isSaved(property.propertyId) == wasSaved;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text(
            failed
                ? 'تعذّر الحفظ، حاول مرة أخرى'
                : (wasSaved
                    ? 'تمت إزالة العقار من المحفوظات'
                    : 'تم حفظ العقار'),
          ),
          action: failed
              ? null
              : SnackBarAction(
                  label: 'تراجع',
                  onPressed: () => repo.toggle(property.propertyId),
                ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final saved = SavedPropertiesRepository.instance;
    return ListenableBuilder(
      listenable: saved, // redraws when the saved list changes
      builder: (context, _) {
        final isSaved = saved.isSaved(property.propertyId);
        return Material(
          color: isSaved ? AppColors.brown : AppColors.gradientStart,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _toggle(context),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.white : AppColors.brown,
                semanticLabel: isSaved ? 'محفوظ' : 'حفظ',
              ),
            ),
          ),
        );
      },
    );
  }
}