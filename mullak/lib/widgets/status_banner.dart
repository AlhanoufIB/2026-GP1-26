import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The app's confirmation / error message box: green with a check for
/// success, red with an X for errors. Same look as the banner on
/// "عقاراتي" (my_properties_screen.dart), so every page shows messages
/// the same way.
class StatusBanner extends StatelessWidget {
  final String text;
  final bool isError;

  const StatusBanner(this.text, {super.key, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final bg = isError ? AppColors.dangerSoft : AppColors.success;
    final fg = isError ? AppColors.danger : AppColors.successText;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(isError ? Icons.close : Icons.check, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: fg)),
          ),
        ],
      ),
    );
  }
}

/// Add to a page's State to get showBanner() and banner():
///
///   class _MyPageState extends State<MyPage> with StatusBannerMixin { ... }
///   showBanner('تم الحفظ');               // green
///   showBanner('حدث خطأ', error: true);   // red
///   ...and put banner() where the message should appear.
///
/// Like "عقاراتي", the message disappears after 4 seconds.
mixin StatusBannerMixin<T extends StatefulWidget> on State<T> {
  String? _bannerText;
  bool _bannerIsError = false;

  void showBanner(String text, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _bannerText = text;
      _bannerIsError = error;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _bannerText == text) setState(() => _bannerText = null);
    });
  }

  Widget banner() => _bannerText == null
      ? const SizedBox.shrink()
      : StatusBanner(_bannerText!, isError: _bannerIsError);
}
