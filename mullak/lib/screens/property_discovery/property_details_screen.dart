import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import 'utils/discovery_formatters.dart';
import 'widgets/property_gallery.dart';
import '../../repositories/saved_properties_repository.dart';
import '../../repositories/chat_repository.dart';
import '../chat/chat_details_screen.dart';

/// "تفاصيل العقار"
/// Two versions from the design:
///  - opened from Explore          -> matchScore is null (no badge)
///  - opened from Recommendations  -> matchScore is set  (green badge)
class PropertyDetailsScreen extends StatelessWidget {
  final Property property;
  final int? matchScore; // 0-100, only when coming from recommendations

  const PropertyDetailsScreen({
    super.key,
    required this.property,
    this.matchScore,
  });

  /// Open an existing conversation or create a new one.
  void _openOwnerChat(BuildContext context) {
    final repository = ChatRepository.instance;

    final conversation =
        repository.getOrCreateConversation(property);

    repository.markAsRead(conversation);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailsScreen(
          conversation: conversation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhoto(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 18),
                  _buildPriceRow(),
                  const SizedBox(height: 18),
                  _buildInfoBoxes(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  /// 1) Full-width photo with "رجوع" on top (Stack = position: absolute)
  Widget _buildPhoto(BuildContext context) {
    return SizedBox(
      height: 345,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: PropertyGallery(images: property.imageUrls),
          ),
          Positioned(
            top: 48,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'رجوع',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2) Title + "الرياض · العليا · رقم العقار 10482"
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${property.city} · ${property.district} · رقم العقار ${property.propertyId}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }

  /// 3) Price on the right, match badge on the left (only if matchScore)
  Widget _buildPriceRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            formatYearlyRent(property.rentPrice),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.brown,
            ),
          ),
        ),
        if (matchScore != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEFE3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$matchScore% ملاءمة لنشاطك',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F5A3A),
              ),
            ),
          ),
      ],
    );
  }

  /// 4) Three boxes: area, type, parking
  Widget _buildInfoBoxes() {
    final parking = property.hasParking == null
        ? 'غير محدد'
        : (property.hasParking! ? 'متوفرة' : 'غير متوفرة');

    return Row(
      children: [
        Expanded(
          child: _InfoBox(
            value: formatArea(property.areaSqm),
            label: 'المساحة',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoBox(
            value: property.typeLabel,
            label: 'النوع',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoBox(
            value: parking,
            label: 'المواقف',
          ),
        ),
      ],
    );
  }

  /// 5) White "وصف العقار" card
  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'وصف العقار',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.description ?? 'لا يوجد وصف',
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }

  /// 6) Bottom bar: "حفظ" (right) and "محادثة المالك" (left)
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: ListenableBuilder(
                  listenable: SavedPropertiesRepository.instance,
                  builder: (context, _) {
                    final saved =
                        SavedPropertiesRepository.instance.isSaved(
                      property.propertyId,
                    );

                    return SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            SavedPropertiesRepository.instance.toggle(
                          property.propertyId,
                        ),
                        icon: Icon(
                          saved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: AppColors.brownDark,
                        ),
                        label: Text(
                          saved ? 'محفوظ' : 'حفظ',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: AppColors.brown,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: PrimaryButton(
                  text: 'محادثة المالك',
                  onPressed: () => _openOwnerChat(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One small info box (value on top, label under it)
class _InfoBox extends StatelessWidget {
  final String value;
  final String label;

  const _InfoBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.hint,
            ),
          ),
        ],
      ),
    );
  }
}
