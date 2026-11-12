import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Temporary unread notification state.
  // Shared between the notifications screen and map.
  static final ValueNotifier<Set<int>> unreadIds =
      ValueNotifier<Set<int>>({1, 2});

  static const Color _unreadBackground =
      Color(0xFFF8F3EA);

  static const Color _iconBackground =
      Color(0xFFF1E7CB);

  static const Color _unreadBorder =
      Color(0xFFCBB69D);

  static const Color _redDot =
      Color(0xFFD94D3D);

  // Mock notifications until Firebase integration.
  static const List<_NotificationItem> _notifications = [
    _NotificationItem(
      id: 1,
      title: 'عقار جديد يناسب نشاطك في الملقا',
      description:
          'محل بمساحة 70 م² بنسبة ملاءمة 92% لبحثك عن مقهى.',
      time: 'قبل 10 دقائق',
      icon: Icons.home_outlined,
    ),
    _NotificationItem(
      id: 2,
      title: 'تغيّر في أسعار الإيجار بحي العليا',
      description:
          'تغيّر متوسط إيجار المحلات التجارية هذا الشهر.',
      time: 'قبل ساعتين',
      icon: Icons.show_chart_rounded,
    ),
    _NotificationItem(
      id: 3,
      title: 'رسالة جديدة من محمد العتيبي',
      description:
          'يمكننا تقسيم الدفعة إلى دفعتين.',
      time: 'أمس',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    _NotificationItem(
      id: 4,
      title: 'تحديث على عقار محفوظ',
      description:
          'تغيّر إيجار الوحدة التجارية في حطين.',
      time: 'قبل يومين',
      icon: Icons.bookmark_border_rounded,
    ),
  ];

  void _markAllAsRead() {
    unreadIds.value = <int>{};
  }

  void _markAsRead(int id) {
    unreadIds.value = {
      ...unreadIds.value,
    }..remove(id);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ValueListenableBuilder<Set<int>>(
            valueListenable: unreadIds,
            builder: (context, unread, _) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  20, 24, 20, 24,
                ),
                children: [
                  _buildBackButton(context),

                  const SizedBox(height: 8),

                  _buildHeader(),

                  const SizedBox(height: 20),

                  for (final notification
                      in _notifications)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _buildNotificationCard(
                        notification,
                        unread.contains(notification.id),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Back button at the top right.
  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back,
                size: 16,
                color: AppColors.brown,
              ),
              SizedBox(width: 5),
              Text(
                'رجوع',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page title and mark-all-as-read action.
  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'التنبيهات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark,
            ),
          ),
        ),

        InkWell(
          onTap: _markAllAsRead,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 2,
            ),
            child: Text(
              'تحديد الكل كمقروء',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Individual notification card.
  Widget _buildNotificationCard(
    _NotificationItem notification,
    bool isUnread,
  ) {
    return Material(
      color: isUnread
          ? _unreadBackground
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUnread
              ? _unreadBorder
              : AppColors.border,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _markAsRead(notification.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // Notification type icon.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBackground,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  notification.icon,
                  size: 23,
                  color: AppColors.brown,
                ),
              ),

              const SizedBox(width: 12),

              // Notification content.
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownDark,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notification.description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.hint,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notification.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Red dot for unread notifications.
              SizedBox(
                width: 9,
                child: isUnread
                    ? Container(
                        margin: const EdgeInsets.only(
                          top: 6,
                        ),
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: _redDot,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Temporary notification data model.
class _NotificationItem {
  final int id;
  final String title;
  final String description;
  final String time;
  final IconData icon;

  const _NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });
}