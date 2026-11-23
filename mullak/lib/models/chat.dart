import 'property.dart';

class ChatMessage {
  final String? messageId;
  final String? senderId;
  final DateTime? sentAt;
  final String text;
  final bool isMine;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
    this.messageId,
    this.senderId,
    this.sentAt,
  });
}

class ChatConversation {
  final String? chatId;
  final String? businessOwnerId;

  // Property details may not be loaded yet.
  final Property? property;

  final String? _propertyId;
  final String? _ownerId;

  final String ownerName;
  final List<ChatMessage> messages;

  String lastTime;
  bool isUnread;
  String? lastMessageText;

  ChatConversation({
    required this.ownerName,
    required this.lastTime,
    this.chatId,
    this.businessOwnerId,
    this.property,
    String? propertyId,
    String? ownerId,
    this.lastMessageText,
    this.isUnread = false,
    List<ChatMessage> messages = const [],
  })  : assert(
          property != null ||
              (propertyId != null && ownerId != null),
          'Provide a property or both propertyId and ownerId.',
        ),
        _propertyId = propertyId,
        _ownerId = ownerId,
        messages = List.of(messages);

  String get propertyId =>
      property?.propertyId ?? _propertyId ?? '';

  String get ownerId =>
      property?.ownerId ?? _ownerId ?? '';

  String get initial =>
      ownerName.isEmpty ? 'م' : ownerName.substring(0, 1);

  String get propertyLabel {
    final currentProperty = property;

    if (currentProperty == null) {
      return 'عقار رقم $propertyId';
    }

    final district = currentProperty.district.trim();

    if (district.isEmpty) {
      return '${currentProperty.typeLabel} · رقم $propertyId';
    }

    return '${currentProperty.typeLabel} $district · رقم $propertyId';
  }

  String get lastMessage {
    if (messages.isNotEmpty) {
      return messages.last.text;
    }

    if (lastMessageText != null &&
        lastMessageText!.isNotEmpty) {
      return lastMessageText!;
    }

    return 'ابدأ المحادثة الآن';
  }
}