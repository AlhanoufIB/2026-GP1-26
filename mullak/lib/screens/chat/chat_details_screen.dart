import 'package:flutter/material.dart';

import '../../models/chat.dart';
import '../../repositories/chat_repository.dart';
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

  final ChatRepository _repository =
      ChatRepository.instance;

  static const Color _avatarColor = Color(0xFFEDE3C9);

  ChatConversation get _conversation => widget.conversation;

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    _repository.sendMessage(
      _conversation,
      text,
    );

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brownDark,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'مالك العقار · ${_conversation.propertyLabel}',
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

  Widget _buildMessages() {
    return Expanded(
      child: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          final messages = _conversation.messages;

          if (messages.isEmpty) {
            return const Center(
              child: Text(
                'ابدأ محادثتك مع مالك العقار',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.hint,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.fromLTRB(
                  16, 14, 16, 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 26)
                        .clamp(0.0, double.infinity)
                        .toDouble(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            messages.first.time == 'أمس'
                                ? 'أمس'
                                : messages.first.time == 'الأحد'
                                    ? 'الأحد'
                                    : 'اليوم',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.hint,
                            ),
                          ),
                        ),
                      ),

                      for (final message in messages)
                        _messageBubble(message),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
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
                textDirection: TextDirection.rtl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,

                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.brownDark,
                ),

                decoration: InputDecoration(
                  hintText: 'اكتب رسالة',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.hint,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Material(
              color: AppColors.brown,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sendMessage,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
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