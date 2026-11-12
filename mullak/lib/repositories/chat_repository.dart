import 'package:flutter/material.dart';

import '../data/sample_properties.dart';
import '../models/property.dart';
import '../models/chat.dart';

class ChatRepository extends ChangeNotifier {
  ChatRepository._() {
    _seedConversations();
  }

  static final ChatRepository instance = ChatRepository._();

  final List<ChatConversation> _conversations = [];

  // Temporary owner names until Firebase is connected.
  static const Map<String, String> _ownerNames = {
    'owner_1': 'محمد العتيبي',
    'owner_2': 'خالد الدوسري',
    'owner_3': 'سارة القحطاني',
  };

  List<ChatConversation> get conversations =>
      List.unmodifiable(_conversations);

  String ownerNameFor(String ownerId) {
    return _ownerNames[ownerId] ?? 'مالك العقار';
  }

  Property _propertyById(String id) {
    return sampleProperties.firstWhere(
      (property) => property.propertyId == id,
    );
  }

  void _seedConversations() {
    _conversations.addAll([
      ChatConversation(
        property: _propertyById('10482'),
        ownerName: ownerNameFor('owner_1'),
        lastTime: '10:24 ص',
        isUnread: true,
        messages: const [
          ChatMessage(
            text: 'السلام عليكم، هل المحل ما زال متاحاً للإيجار؟',
            isMine: true,
            time: '10:20 ص',
          ),
          ChatMessage(
            text: 'وعليكم السلام، نعم متاح. هل ترغب بمعاينته؟',
            isMine: false,
            time: '10:21 ص',
          ),
          ChatMessage(
            text: 'نعم، وهل يمكن تقسيم دفعة الإيجار السنوية؟',
            isMine: true,
            time: '10:23 ص',
          ),
          ChatMessage(
            text: 'يمكننا تقسيمها إلى دفعتين. متى يناسبك الموعد؟',
            isMine: false,
            time: '10:24 ص',
          ),
        ],
      ),

      ChatConversation(
        property: _propertyById('10561'),
        ownerName: ownerNameFor('owner_3'),
        lastTime: 'أمس',
        messages: const [
          ChatMessage(
            text: 'السلام عليكم، لدي استفسار عن المكتب.',
            isMine: true,
            time: 'أمس',
          ),
          ChatMessage(
            text: 'وعليكم السلام، تفضل.',
            isMine: false,
            time: 'أمس',
          ),
          ChatMessage(
            text: 'هل المكتب متاح للمعاينة هذا الأسبوع؟',
            isMine: true,
            time: 'أمس',
          ),
        ],
      ),

      ChatConversation(
        property: _propertyById('10517'),
        ownerName: ownerNameFor('owner_2'),
        lastTime: 'الأحد',
        messages: const [
          ChatMessage(
            text: 'السلام عليكم، هل المحل متاح للإيجار؟',
            isMine: true,
            time: 'الأحد',
          ),
          ChatMessage(
            text: 'وعليكم السلام، نعم المحل متاح.',
            isMine: false,
            time: 'الأحد',
          ),
          ChatMessage(
            text: 'شكراً لك، سأراجعكم قريباً.',
            isMine: true,
            time: 'الأحد',
          ),
        ],
      ),
    ]);
  }

  // Find the existing conversation or create a new one.
  ChatConversation getOrCreateConversation(Property property) {
    for (final conversation in _conversations) {
      if (conversation.propertyId == property.propertyId &&
          conversation.ownerId == property.ownerId) {
        return conversation;
      }
    }

    final conversation = ChatConversation(
      property: property,
      ownerName: ownerNameFor(property.ownerId),
      lastTime: 'الآن',
    );

    _conversations.insert(0, conversation);
    notifyListeners();

    return conversation;
  }

  void markAsRead(ChatConversation conversation) {
    if (!conversation.isUnread) return;

    conversation.isUnread = false;
    notifyListeners();
  }

  void sendMessage(
    ChatConversation conversation,
    String text,
  ) {
    final message = text.trim();

    if (message.isEmpty) return;

    final time = _currentTime();

    conversation.messages.add(
      ChatMessage(
        text: message,
        isMine: true,
        time: time,
      ),
    );

    conversation.lastTime = time;
    conversation.isUnread = false;

    // Move the most recent conversation to the top.
    _conversations.remove(conversation);
    _conversations.insert(0, conversation);

    notifyListeners();
  }

  String _currentTime() {
    final now = DateTime.now();

    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'ص' : 'م';

    return '$hour:$minute $period';
  }
}