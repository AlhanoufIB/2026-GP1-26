import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'feedback_service.dart';
import 'widgets/back_link.dart';
import 'widgets/primary_button.dart';
import 'widgets/text_area_field.dart';

/// "كتابة تقييم"
class RateExperienceScreen extends StatefulWidget {
  const RateExperienceScreen({super.key});

  @override
  State<RateExperienceScreen> createState() => _RateExperienceScreenState();
}

class _RateExperienceScreenState extends State<RateExperienceScreen> {
  int _rating = 0; // 0 = nothing chosen yet, otherwise 1 to 5
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
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

    if (_rating == 0) {
      _snack('اختر عدد النجوم');
      return;
    }

    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await FeedbackService.instance.submitRating(
        stars: _rating,
        comment: _commentCtrl.text.trim(),
      );
      if (!mounted) return;
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('شكراً لك، تم إرسال تقييمك')),
        );
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
                      'كتابة تقييم',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'رأيك يهمنا ويساعدنا على تحسين تجربتك في مُلّاك',
                      style: TextStyle(fontSize: 12.5, color: AppColors.hint),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'تقييمك',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Stars: the first star is on the right.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 5; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _rating = i + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Icon(
                                i < _rating ? Icons.star : Icons.star_border,
                                size: 32,
                                color: AppColors.brown,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 22),

                    TextAreaField(
                      label: 'تجربتك',
                      hint: 'كيف كانت تجربتك مع مُلّاك؟ وما الذي يمكننا تحسينه؟',
                      controller: _commentCtrl,
                      lines: 6,
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: 'إرسال التقييم',
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