import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/property_discovery/explore_properties_screen.dart';
import 'theme/app_colors.dart';

/// TEMPORARY entry point for testing the property discovery pages
/// (Student 4) on their own, without touching the team's main.dart.
///
/// Run it with:   flutter run -t lib/main_discovery.dart
///
/// Uses the same theme, font and right-to-left setup as main.dart.
/// Delete this file once the pages are connected to the bottom nav bar.
void main() {
  runApp(const DiscoveryPreviewApp());
}

class DiscoveryPreviewApp extends StatelessWidget {
  const DiscoveryPreviewApp({super.key});

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const ExplorePropertiesScreen(),
    );
  }
}
