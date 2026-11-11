import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

/// يرجع true إذا أكّد المستخدم الحذف
Future<bool> showDeletePropertyDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.danger, size: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              'حذف هذا العقار؟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لن يظهر العقار لأي مستخدم بعد الآن، ولا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(
                fontSize: 13,
                height: 1.7,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (ctx) => Column(
                children: [
                  CustomButton(
                    text: 'نعم، احذف العقار',
                    type: CustomButtonType.danger,
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'إلغاء',
                    type: CustomButtonType.outlined,
                    onPressed: () => Navigator.pop(ctx, false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}