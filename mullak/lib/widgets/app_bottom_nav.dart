import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The main sections of the app (the bottom bar).
enum AppTab { map, explore, myProperties, chats, account }

/// Bottom navigation bar shared by all the main pages.
///
/// How to use it on a page:
///
///   AppBottomNav(
///     current: AppTab.explore,            // the tab this page belongs to
///     onTabSelected: (tab) { ... },       // open the page of that tab
///   )
///
/// Put it at the bottom of the page, for example as
/// `bottomNavigationBar:` of the Scaffold.
class AppBottomNav extends StatelessWidget {
  final AppTab current;
  final ValueChanged<AppTab> onTabSelected;

  const AppBottomNav({
    super.key,
    required this.current,
    required this.onTabSelected,
  });

  // The app is right-to-left, so the FIRST item is on the right.
  static const _items = <_NavItem>[
    _NavItem(AppTab.map, Icons.location_on_outlined, 'الخريطة'),
    _NavItem(AppTab.explore, Icons.search, 'استكشاف'),
    _NavItem(AppTab.myProperties, Icons.home_outlined, 'عقاراتي'),
    _NavItem(AppTab.chats, Icons.chat_bubble_outline, 'المحادثات'),
    _NavItem(AppTab.account, Icons.person_outline, 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
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
                    onTap: () => onTabSelected(item.tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final AppTab tab;
  final IconData icon;
  final String label;

  const _NavItem(this.tab, this.icon, this.label);
}

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
    final color = selected ? AppColors.brownDark : _inactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}