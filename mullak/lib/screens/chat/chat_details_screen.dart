import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat.dart';
import '../../services/chat_firestore_service.dart';
import '../../theme/app_colors.dart';

class ChatDetailsScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatDetailsScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatDetailsScreen> createState() =>
      _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final ChatFirestoreService _chatService =
      ChatFirestoreService.instance;

  static const Color _avatarColor = Color(0xFFEDE3C9);
  static const int _maxMessageLength = 2000;

  Stream<QuerySnapshot<Map<String, dynamic>>>?
      _messagesStream;

  // The chat ID becomes available after the first message.
  String? _activeChatId;

  bool _isSending = false;

  // Prevent duplicate read updates while a request is running.
  final Set<String> _pendingReadIds = {};

  ChatConversation get _conversation => widget.conversation;

  String? get _chatId => _activeChatId;

  // Allow sending to an existing conversation or
  // starting a valid new conversation.
  bool get _canSend {
    if (_isSending) return false;

    if (_chatId != null && _chatId!.isNotEmpty) {
      return true;
    }

    return _conversation.propertyId.trim().isNotEmpty &&
        _conversation.ownerId.trim().isNotEmpty &&
        _conversation.businessOwnerId ==
            _chatService.currentUserId &&
        _conversation.ownerId != _chatService.currentUserId;
  }

  String get _otherParticipantRole {
    if (_chatService.currentUserId == _conversation.ownerId) {
      return 'صاحب النشاط';
    }
    return 'مالك العقار';
  }

  @override
  void initState() {
    super.initState();

    final initialChatId = _conversation.chatId;

    _activeChatId =
        initialChatId != null && initialChatId.isNotEmpty
            ? initialChatId
            : null;

    final chatId = _chatId;

    // Listen immediately only if the conversation exists.
    if (chatId != null) {
      _messagesStream = _chatService.watchMessages(chatId);
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'الآن';

    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';

    return '$hour:$minute $period';
  }

  String _formatDay(DateTime? date) {
    if (date == null) return 'اليوم';

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final messageDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference = today.difference(messageDay).inDays;

    if (difference == 0) return 'اليوم';
    if (difference == 1) return 'أمس';

    return '${date.day}/${date.month}/${date.year}';
  }

  bool _sameDay(DateTime? first, DateTime? second) {
    if (first == null || second == null) {
      return first == null && second == null;
    }

    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  ChatMessage _messageFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final timestamp = data['sentAt'];

    final DateTime? sentAt =
        timestamp is Timestamp ? timestamp.toDate() : null;

    final senderId = data['senderId'] as String? ?? '';

    return ChatMessage(
      messageId: document.id,
      senderId: senderId,
      sentAt: sentAt,
      text: data['content'] as String? ?? '',
      isMine: senderId == _chatService.currentUserId,
      time: _formatTime(sentAt),
    );
  }

  // Mark incoming unread messages as read after rendering.
  void _scheduleReadUpdates(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final chatId = _chatId;
    if (chatId == null || chatId.isEmpty) return;

    final userId = _chatService.currentUserId;

    final unreadDocuments = documents.where((document) {
      final data = document.data();
      final senderId = data['senderId'] as String? ?? '';

      return senderId.isNotEmpty &&
          senderId != userId &&
          data['isRead'] != true &&
          !_pendingReadIds.contains(document.id);
    }).toList();

    if (unreadDocuments.isEmpty) return;

    final ids = unreadDocuments.map((doc) => doc.id).toList();

    _pendingReadIds.addAll(ids);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _pendingReadIds.removeAll(ids);
        return;
      }

      try {
        await _chatService.markMessagesAsRead(
          chatId: chatId,
          messages: unreadDocuments,
        );
      } catch (error) {
        debugPrint('Mark messages as read error: $error');
      } finally {
        _pendingReadIds.removeAll(ids);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final chatId = _chatId;

    if (text.isEmpty || !_canSend) {
      return;
    }

    if (text.length > _maxMessageLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرسالة طويلة جدًا. الحد الأقصى 2000 حرف.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      if (chatId == null) {
        // Create the conversation and its first message
        // together in Firestore.
        final newChatId =
            await _chatService.sendFirstMessage(
          propertyId: _conversation.propertyId,
          propertyOwnerId: _conversation.ownerId,
          text: text,
        );

        if (!mounted) return;

        // Start listening only after successful creation.
        setState(() {
          _activeChatId = newChatId;
          _messagesStream =
              _chatService.watchMessages(newChatId);
        });
      } else {
        // Send normally to an existing conversation.
        await _chatService.sendMessage(
          chatId: chatId,
          text: text,
        );
      }

      if (!mounted) return;

      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    } catch (error) {
      debugPrint('Chat send error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر إرسال الرسالة. حاول مرة أخرى.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              size: 23,
              color: AppColors.brown,
            ),
          ),

          CircleAvatar(
            radius: 24,
            backgroundColor: _avatarColor,
            child: Text(
              _conversation.initial,
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
                  _conversation.ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brownDark,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$_otherParticipantRole · ${_conversation.propertyLabel}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: message.isMine
              ? AppColors.brown
              : Colors.white,

          border: message.isMine
              ? null
              : Border.all(
                  color: AppColors.border,
                ),

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(17),
            topRight: const Radius.circular(17),
            bottomLeft: Radius.circular(
              message.isMine ? 17 : 5,
            ),
            bottomRight: Radius.circular(
              message.isMine ? 5 : 17,
            ),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: message.isMine
                ? Colors.white
                : AppColors.brownDark,
          ),
        ),
      ),
    );
  }

  Widget _dateSeparator(DateTime? date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Text(
          _formatDay(date),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.hint,
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    // A new conversation does not have a Firestore
    // document until the first message is sent.
    if (_messagesStream == null) {
      return const Expanded(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'ابدأ المحادثة الآن',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.hint,
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'تعذر تحميل الرسائل. تحقق من الاتصال.',
                style: TextStyle(
                  fontSize: 13,
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

          final documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Center(
              child: Text(
                'ابدأ المحادثة الآن',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.hint,
                ),
              ),
            );
          }

          // Automatically mark received messages as read.
          _scheduleReadUpdates(documents);

          final messages = documents
              .map(_messageFromDocument)
              .toList();

          final items = <Widget>[];

          DateTime? previousDate;
          bool isFirstMessage = true;

          for (final message in messages) {
            if (isFirstMessage ||
                !_sameDay(previousDate, message.sentAt)) {
              items.add(_dateSeparator(message.sentAt));
            }

            items.add(_messageBubble(message));

            previousDate = message.sentAt;
            isFirstMessage = false;
          }

          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(
              16, 14, 16, 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return items[items.length - 1 - index];
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    final canSend = _canSend;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16, 12, 16, 12,
      ),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: canSend,
                textDirection: TextDirection.rtl,
                minLines: 1,
                maxLines: 4,
                maxLength: _maxMessageLength,
                maxLengthEnforcement:
                    MaxLengthEnforcement.enforced,
                textInputAction: TextInputAction.newline,

                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.brownDark,
                ),

                decoration: InputDecoration(
                  hintText: 'اكتب رسالة',
                  counterText: '',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.hint,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Material(
              color: canSend
                  ? AppColors.brown
                  : AppColors.hint,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: canSend ? _sendMessage : null,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                          size: 23,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              _buildMessages(),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }
}