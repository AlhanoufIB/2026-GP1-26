import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'feedback_service.dart';
import 'widgets/back_link.dart';
import 'widgets/primary_button.dart';
import 'widgets/text_area_field.dart';

/// "الإبلاغ عن مشكلة"
class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  static const _types = [
    'العقار قديم أو لم يعد متاحًا',
    'سعر أو بيانات غير صحيحة',
    'إعلان مشبوه أو وهمي',
    'مشكلة في التطبيق',
    'أخرى',
  ];

  int? _selected;
  final _detailsCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();

    if (_selected == null) {
      _snack('اختر نوع المشكلة');
      return;
    }
    final details = _detailsCtrl.text.trim();
    final isOther = _selected == _types.length - 1;
    if (isOther && details.isEmpty) {
      _snack('اشرح المشكلة في خانة التفاصيل');
      return;
    }

    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await FeedbackService.instance.submitReport(
        type: _types[_selected!],
        details: details,
      );
      if (!mounted) return;
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تم إرسال البلاغ، شكراً لك')));
    } catch (_) {
      _snack('تعذّر الإرسال، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackLink(),
                    const SizedBox(height: 8),
                    const Text(
                      'الإبلاغ عن مشكلة',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'أخبرنا بما حدث لنتحقق منه.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.hint),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'ما نوع المشكلة؟',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _types.length; i++) ...[
                      if (i > 0) const SizedBox(height: 9),
                      _ProblemOption(
                        text: _types[i],
                        selected: _selected == i,
                        onTap: () => setState(() => _selected = i),
                      ),
                    ],
                    const SizedBox(height: 26),
                    TextAreaField(
                      label: 'التفاصيل',
                      hint: 'اشرح المشكلة',
                      controller: _detailsCtrl,
                      lines: 4,
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: 'إرسال البلاغ',
                      loading: _sending,
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One selectable row with a radio circle (right) and the text.
class _ProblemOption extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ProblemOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: selected ? const Color(0xFFF5EEDC) : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.brownDark : AppColors.border,
            width: selected ? 1.4 : 1.2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Radio circle (first child = right side)
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.brown : const Color(0xFF8A7B70),
                      width: 1.6,
                    ),
                  ),
                  child: selected
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.brown,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: AppColors.brownDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}