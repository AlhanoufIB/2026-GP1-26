import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import 'rate_experience_screen.dart';
import 'report_problem_screen.dart';
import 'welcome_screen.dart';
import '../../widgets/app_bottom_nav.dart';

/// "حسابي": the first page after login, for now.
class AccountScreen extends StatelessWidget {
  /// The user's phone (+9665XXXXXXXX), shown under the name.
  final String? phone;

  const AccountScreen({super.key, this.phone});

  // TODO: replace with the real number of the user's properties.
  static const _demoPropertiesCount = 2;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _logout(BuildContext context) {
    AuthService.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.instance.currentUserName ?? 'مستخدم مُلّاك';
    final trimmed = name.trim();
    final initial = trimmed.isEmpty
        ? '؟'
        : String.fromCharCode(trimmed.runes.first);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حسابي',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile card
                    _Card(
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.brown,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brownDark,
                                  ),
                                ),
                                if (phone != null) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    formatPhone(phone!),
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.hint,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Number of properties
                    const _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_demoPropertiesCount',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brownDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'عقاراتي',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _MenuRow(
                      label: 'الإبلاغ عن مشكلة',
                      trailing: Icons.chevron_left,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportProblemScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MenuRow(
                      label: 'قيم تجربتك',
                      trailing: Icons.chevron_left,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RateExperienceScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MenuRow(
                      label: 'تواصل معنا',
                      trailing: Icons.phone_outlined,
                      // TODO: open the real contact details when we have them.
                      onTap: () =>
                          _snack(context, 'وسيلة التواصل ستتوفر قريباً'),
                    ),
                  ],
                ),
              ),
            ),

            // Logout button, always above the bottom bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _logout(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const AppBottomNav(
  current: AppTab.account,
),
          ],
        ),
      ),
    );
  }
}

/// White rounded card with a beige border. Tappable when [onTap] is given.
class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const _Card({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String label;
  final IconData trailing;
  final VoidCallback onTap;

  const _MenuRow({
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDark,
              ),
            ),
          ),
          Icon(trailing, size: 20, color: AppColors.brownDark),
        ],
      ),
    );
  }
}
