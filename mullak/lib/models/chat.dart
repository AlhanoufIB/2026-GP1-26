import 'property.dart';

class ChatMessage {
  final String text;
  final bool isMine;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
  });
}

class ChatConversation {
  final Property property;
  final String ownerName;

  final List<ChatMessage> messages;

  String lastTime;
  bool isUnread;

  ChatConversation({
    required this.property,
    required this.ownerName,
    required this.lastTime,
    this.isUnread = false,
    List<ChatMessage> messages = const [],
  }) : messages = List.of(messages);

  String get propertyId => property.propertyId;

  String get ownerId => property.ownerId;

  String get initial =>
      ownerName.isEmpty ? 'م' : ownerName.substring(0, 1);

  String get propertyLabel =>
      '${property.typeLabel} ${property.district} · رقم $propertyId';

  String get lastMessage =>
      messages.isEmpty ? 'ابدأ المحادثة الآن' : messages.last.text;
}