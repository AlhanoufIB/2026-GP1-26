import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Screens
import '../screens/map/map_screen.dart';
import '../screens/authentication/account_screen.dart';
import '../screens/property_discovery/explore_properties_screen.dart';
import '../screens/property_management/my_properties_screen.dart';

// Navigation tabs
enum AppTab {
  map,
  explore,
  myProperties,
  chats,
  account,
}

class AppBottomNav extends StatelessWidget {
  final AppTab current;

  const AppBottomNav({
    super.key,
    required this.current,
  });

  // Navigation bar items
  static const _items = <_NavItem>[
    _NavItem(
      AppTab.map,
      Icons.location_on_outlined,
      'الخريطة',
    ),
    _NavItem(
      AppTab.explore,
      Icons.search,
      'استكشاف',
    ),
    _NavItem(
      AppTab.myProperties,
      Icons.home_outlined,
      'عقاراتي',
    ),
    _NavItem(
      AppTab.chats,
      Icons.chat_bubble_outline,
      'المحادثات',
    ),
    _NavItem(
      AppTab.account,
      Icons.person_outline,
      'حسابي',
    ),
  ];

  // Get the screen associated with the selected tab
  Widget? _getScreen(AppTab tab) {
    switch (tab) {
      case AppTab.map:
        return const MapScreen();

      case AppTab.explore:
        return const ExplorePropertiesScreen();

      case AppTab.myProperties:
        return const MyPropertiesScreen();

      case AppTab.account:
        return const AccountScreen();

      case AppTab.chats:
        // Chats screen will be connected later
        return null;
    }
  }

  // Handle navigation between screens
  void _navigate(BuildContext context, AppTab selectedTab) {

    // Stay on the same screen if already selected
    if (selectedTab == current) return;

    // Get destination screen
    final screen = _getScreen(selectedTab);

    // Do nothing if the screen is not available yet
    if (screen == null) return;

    // Navigate to the selected screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Row(
            children: [
              for (final item in _items)
                Expanded(
                  child: _NavButton(
                    item: item,
                    selected: item.tab == current,
                    onTap: () => _navigate(
                      context,
                      item.tab,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Navigation item model
class _NavItem {
  final AppTab tab;
  final IconData icon;
  final String label;

  const _NavItem(
    this.tab,
    this.icon,
    this.label,
  );
}

// Navigation button widget
class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  static const _inactive = Color(0xFF7D6F64);

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.brownDark
        : _inactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
