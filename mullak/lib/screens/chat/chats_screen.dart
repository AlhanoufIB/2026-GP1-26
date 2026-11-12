import 'package:flutter/material.dart';

import '../../models/chat.dart';
import '../../repositories/chat_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';

import '../map/map_screen.dart';
import '../property_discovery/explore_properties_screen.dart';
import '../property_management/my_properties_screen.dart';
import '../authentication/account_screen.dart';

import 'chat_details_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  static const Color _avatarColor = Color(0xFFEDE3C9);
  static const Color _unreadColor = Color(0xFFD94B40);

  void _openChat(
    BuildContext context,
    ChatConversation conversation,
  ) {
    ChatRepository.instance.markAsRead(conversation);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailsScreen(
          conversation: conversation,
        ),
      ),
    );
  }

  Widget _chatCard(
    BuildContext context,
    ChatConversation conversation,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openChat(context, conversation),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Owner avatar.
              CircleAvatar(
                radius: 23,
                backgroundColor: _avatarColor,
                child: Text(
                  conversation.initial,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brown,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Owner name, property and last message.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownDark,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      conversation.propertyLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.hint,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: conversation.isUnread
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: AppColors.brownDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Time and unread indicator.
              SizedBox(
                width: 57,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      conversation.lastTime,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.hint,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: conversation.isUnread
                            ? _unreadColor
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = ChatRepository.instance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المحادثات',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brownDark,
                  ),
                ),

                const SizedBox(height: 22),

                Expanded(
                  child: ListenableBuilder(
                    listenable: repository,
                    builder: (context, _) {
                      final conversations = repository.conversations;

                      if (conversations.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا توجد محادثات حالياً',
                            style: TextStyle(
                              color: AppColors.hint,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: conversations.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _chatCard(
                            context,
                            conversations[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: AppBottomNav(
          current: AppTab.chats,
          onTabSelected: (tab) {
            if (tab == AppTab.chats) return;

            Widget? destination;

            switch (tab) {
              case AppTab.map:
                destination = const MapScreen();
                break;

              case AppTab.explore:
                destination = const ExplorePropertiesScreen();
                break;

              case AppTab.myProperties:
                destination = const MyPropertiesScreen();
                break;

              case AppTab.account:
                destination = const AccountScreen();
                break;

              case AppTab.chats:
                break;
            }

            if (destination != null) {
              final page = destination;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => page,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}