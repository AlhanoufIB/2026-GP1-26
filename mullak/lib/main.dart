import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MullakApp());
}

/// App root: Arabic, right-to-left, custom font + theme.
class MullakApp extends StatelessWidget {
  const MullakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مُلّاك',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brown),
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.brownDark,
          contentTextStyle: GoogleFonts.ibmPlexSansArabic(
            color: Colors.white,
            fontSize: 13,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Force right-to-left layout for the whole app
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const WelcomeScreen(),
    );
  }
}
