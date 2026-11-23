import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat.dart';
import '../../services/chat_firestore_service.dart';
import '../../services/chat_property_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';

import 'chat_details_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  static const Color _avatarColor = Color(0xFFEDE3C9);

  final ChatFirestoreService _chatService =
      ChatFirestoreService.instance;

  final ChatPropertyService _propertyService =
      ChatPropertyService.instance;

  final Map<String, Future<ChatPropertyInfo?>> _propertyCache = {};

  // Cache unread-message streams for each conversation.
  final Map<
      String,
      Stream<QuerySnapshot<Map<String, dynamic>>>>
      _unreadStreams = {};

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _chatsStream;

  @override
  void initState() {
    super.initState();
    _chatsStream = _chatService.watchMyChats();
  }

  Future<ChatPropertyInfo?> _getProperty(String propertyId) {
    return _propertyCache.putIfAbsent(
      propertyId,
      () => _propertyService.getProperty(propertyId),
    );
  }

  // Listen only to unread messages in this conversation.
  Stream<QuerySnapshot<Map<String, dynamic>>> _watchUnreadMessages(
    String chatId,
  ) {
    return _unreadStreams.putIfAbsent(
      chatId,
      () => FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .snapshots(),
    );
  }

  String _formatTime(dynamic value) {
    if (value is! Timestamp) return 'الآن';

    final date = value.toDate();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final messageDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference = today.difference(messageDay).inDays;

    if (difference == 1) return 'أمس';

    if (difference != 0) {
      return '${date.day}/${date.month}/${date.year}';
    }

    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';

    return '$hour:$minute $period';
  }

  String _otherParticipantName({
    required String propertyOwnerId,
    required String businessOwnerName,
    required ChatPropertyInfo? propertyInfo,
  }) {
    final currentUserId = _chatService.currentUserId;

    // The property owner sees the business owner's name.
    if (currentUserId == propertyOwnerId) {
      final name = businessOwnerName.trim();

      return name.isNotEmpty ? name : 'صاحب النشاط';
    }

    // The business owner sees the property owner's name.
    final ownerName = propertyInfo?.ownerName.trim();

    if (ownerName != null && ownerName.isNotEmpty) {
      return ownerName;
    }

    return 'مالك العقار';
  }

  void _openChat(
    BuildContext context,
    ChatConversation conversation,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailsScreen(
          conversation: conversation,
        ),
      ),
    );
  }

  // Show a real-time unread-message count.
  Widget _buildUnreadCount(String chatId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _watchUnreadMessages(chatId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final currentUserId = _chatService.currentUserId;

        // Count messages received from the other participant.
        final unreadCount = snapshot.data!.docs.where((document) {
          final senderId = document.data()['senderId'];

          return senderId is String &&
              senderId.isNotEmpty &&
              senderId != currentUserId;
        }).length;

        if (unreadCount == 0) {
          return const SizedBox.shrink();
        }

        final countText = unreadCount > 99
            ? '99+'
            : unreadCount.toString();

        return Container(
          constraints: const BoxConstraints(
            minWidth: 23,
            minHeight: 23,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          decoration: const BoxDecoration(
            color: AppColors.brown,
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
          ),
          child: Center(
            child: Text(
              countText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.brownDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      conversation.lastTime,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.hint,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (conversation.chatId != null)
                      _buildUnreadCount(
                        conversation.chatId!,
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

  Widget _buildChatDocument(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final propertyId =
        data['propertyId'] as String? ?? '';

    final ownerId =
        data['propertyOwnerId'] as String? ?? '';

    final businessOwnerId =
        data['businessOwnerId'] as String? ?? '';

    // Name saved when the business owner creates the chat.
    final businessOwnerName =
        data['businessOwnerName'] as String? ?? '';

    final lastMessage =
        data['lastMessageText'] as String? ?? '';

    final lastTime = _formatTime(
      data['lastMessageAt'],
    );

    if (propertyId.isEmpty || ownerId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<ChatPropertyInfo?>(
      future: _getProperty(propertyId),
      builder: (context, snapshot) {
        // Keep chat accessible even if property data
        // is unavailable or still loading.
        final fetchedInfo = snapshot.data;

        final propertyInfo =
            fetchedInfo?.property.ownerId == ownerId
                ? fetchedInfo
                : null;

        final otherParticipant = _otherParticipantName(
          propertyOwnerId: ownerId,
          businessOwnerName: businessOwnerName,
          propertyInfo: propertyInfo,
        );

        final conversation = ChatConversation(
          chatId: document.id,
          businessOwnerId: businessOwnerId,
          property: propertyInfo?.property,
          propertyId: propertyId,
          ownerId: ownerId,
          ownerName: otherParticipant,
          lastTime: lastTime,
          lastMessageText: lastMessage,
        );

        return _chatCard(
          context,
          conversation,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20, 24, 20, 0,
            ),
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
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: _chatsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'تعذر تحميل المحادثات.',
                            style: TextStyle(
                              color: AppColors.hint,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brown,
                          ),
                        );
                      }

                      final documents =
                          snapshot.data!.docs.toList();

                      documents.sort((a, b) {
                        final aTime =
                            a.data()['lastMessageAt'];

                        final bTime =
                            b.data()['lastMessageAt'];

                        final aMillis = aTime is Timestamp
                            ? aTime.millisecondsSinceEpoch
                            : 0;

                        final bMillis = bTime is Timestamp
                            ? bTime.millisecondsSinceEpoch
                            : 0;

                        return bMillis.compareTo(aMillis);
                      });

                      if (documents.isEmpty) {
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
                        padding: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        itemCount: documents.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildChatDocument(
                            context,
                            documents[index],
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

        bottomNavigationBar: const AppBottomNav(
          current: AppTab.chats,
        ),
      ),
    );
  }
}