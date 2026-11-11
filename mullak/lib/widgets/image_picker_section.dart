import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class ImagePickerSection extends StatelessWidget {
  final List<String> images;
  final int mainIndex;
  final ValueChanged<List<String>> onImagesChanged;
  final ValueChanged<int> onMainChanged;

  const ImagePickerSection({
    super.key,
    required this.images,
    required this.mainIndex,
    required this.onImagesChanged,
    required this.onMainChanged,
  });

  Future<void> _pick() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    onImagesChanged([...images, ...picked.map((x) => x.path)]);
  }

  void _remove(int i) {
    final updated = [...images]..removeAt(i);
    onImagesChanged(updated);
    // نضبط الرئيسية بعد الحذف
    if (updated.isEmpty) {
      onMainChanged(0);
    } else if (i == mainIndex) {
      onMainChanged(0);
    } else if (i < mainIndex) {
      onMainChanged(mainIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary),
            ),
            child: const Text('إضافة صور +',
                style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'اضغط على الصورة لتحديدها كصورة رئيسية',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(images.length, (i) {
              final isMain = i == mainIndex;
              return GestureDetector(
                onTap: () => onMainChanged(i),
                child: Stack(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMain ? AppColors.primary : AppColors.border,
                          width: isMain ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(images[i]),
                            fit: BoxFit.cover, width: 84, height: 84),
                      ),
                    ),
                    if (isMain)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('رئيسية',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white)),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: GestureDetector(
                        onTap: () => _remove(i),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}