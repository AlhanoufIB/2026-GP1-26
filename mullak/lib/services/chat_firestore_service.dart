import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_profile_service.dart';

class ChatFirestoreService {
  ChatFirestoreService._();

  static final ChatFirestoreService instance =
      ChatFirestoreService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ChatProfileService _profileService =
      ChatProfileService.instance;

  /// Get the currently signed-in user's UID.
  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not signed in.');
    }

    return user.uid;
  }

  /// Listen to all chats that include the current user.
  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchMyChats() {
    return _firestore
        .collection('chats')
        .where(
          'participantIds',
          arrayContains: currentUserId,
        )
        .snapshots();
  }

  /// Listen to messages in a specific chat.
  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots();
  }

  /// Generate a deterministic chat ID without creating
  /// any Firestore document.
  String buildChatId({
    required String propertyId,
    required String propertyOwnerId,
  }) {
    final businessOwnerId = currentUserId;
    final ownerId = propertyOwnerId.trim();
    final id = propertyId.trim();

    if (id.isEmpty ||
        ownerId.isEmpty ||
        id.contains('/') ||
        ownerId.contains('/')) {
      throw ArgumentError(
        'Invalid property or owner ID.',
      );
    }

    if (businessOwnerId == ownerId) {
      throw StateError(
        'You cannot start a chat with yourself.',
      );
    }

    return '${id}_${businessOwnerId}_$ownerId';
  }

  /// Find an existing conversation without creating one.
  Future<String?> findExistingChat({
    required String propertyId,
    required String propertyOwnerId,
  }) async {
    final businessOwnerId = currentUserId;
    final ownerId = propertyOwnerId.trim();
    final id = propertyId.trim();

    final chatId = buildChatId(
      propertyId: id,
      propertyOwnerId: ownerId,
    );

    final result = await _firestore
        .collection('chats')
        .where(
          'participantIds',
          arrayContains: businessOwnerId,
        )
        .where(
          FieldPath.documentId,
          isEqualTo: chatId,
        )
        .limit(1)
        .get(
          const GetOptions(source: Source.server),
        );

    if (result.docs.isEmpty) {
      return null;
    }

    final document = result.docs.first;
    final data = document.data();
    final participants = data['participantIds'];

    if (data['propertyId'] != id ||
        data['businessOwnerId'] != businessOwnerId ||
        data['propertyOwnerId'] != ownerId ||
        participants is! List ||
        !participants.contains(businessOwnerId) ||
        !participants.contains(ownerId)) {
      throw StateError(
        'Invalid conversation data.',
      );
    }

    return document.id;
  }

  /// Create a conversation only when the first message
  /// is sent. Save both documents atomically.
  Future<String> sendFirstMessage({
    required String propertyId,
    required String propertyOwnerId,
    required String text,
  }) async {
    final message = text.trim();

    if (message.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    if (message.length > 2000) {
      throw ArgumentError('Message is too long.');
    }

    final businessOwnerId = currentUserId;
    final ownerId = propertyOwnerId.trim();
    final id = propertyId.trim();

    final chatId = buildChatId(
      propertyId: id,
      propertyOwnerId: ownerId,
    );

    // Reuse an existing conversation, including
    // previously created empty conversations.
    final existingChatId = await findExistingChat(
      propertyId: id,
      propertyOwnerId: ownerId,
    );

    if (existingChatId != null) {
      await sendMessage(
        chatId: existingChatId,
        text: message,
      );

      return existingChatId;
    }

    final businessOwnerName =
        await _profileService.getCurrentUserName();

    if (businessOwnerName == null ||
        businessOwnerName.trim().isEmpty) {
      throw StateError(
        'Business owner profile name is unavailable.',
      );
    }

    final chatRef =
        _firestore.collection('chats').doc(chatId);

    final messageRef =
        chatRef.collection('messages').doc();

    final batch = _firestore.batch();

    // Create the conversation with its first message
    // already included in the chat preview.
    batch.set(chatRef, {
      'propertyId': id,
      'businessOwnerId': businessOwnerId,
      'businessOwnerName': businessOwnerName.trim(),
      'propertyOwnerId': ownerId,
      'participantIds': [
        businessOwnerId,
        ownerId,
      ],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageText': message,
      'lastSenderId': businessOwnerId,
    });

    // Create the first message in the same batch.
    batch.set(messageRef, {
      'senderId': businessOwnerId,
      'content': message,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    try {
      await batch.commit();
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }

      // Another session may have created the same
      // conversation before this batch was committed.
      final concurrentChatId = await findExistingChat(
        propertyId: id,
        propertyOwnerId: ownerId,
      );

      if (concurrentChatId == null) {
        rethrow;
      }

      await sendMessage(
        chatId: concurrentChatId,
        text: message,
      );

      return concurrentChatId;
    }

    return chatId;
  }

  /// Send a message and update the chat preview.
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final message = text.trim();

    if (chatId.trim().isEmpty) {
      throw ArgumentError('Chat ID cannot be empty.');
    }

    if (message.isEmpty) {
      return;
    }

    if (message.length > 2000) {
      throw ArgumentError('Message is too long.');
    }

    final chatRef =
        _firestore.collection('chats').doc(chatId);

    final messageRef =
        chatRef.collection('messages').doc();

    final batch = _firestore.batch();

    batch.set(messageRef, {
      'senderId': currentUserId,
      'content': message,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    batch.update(chatRef, {
      'lastMessageText': message,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': currentUserId,
    });

    await batch.commit();
  }

  /// Mark messages received from the other user as read.
  Future<void> markMessagesAsRead({
    required String chatId,
    required List<
        QueryDocumentSnapshot<Map<String, dynamic>>>
        messages,
  }) async {
    if (chatId.trim().isEmpty) {
      throw ArgumentError('Chat ID cannot be empty.');
    }

    final userId = currentUserId;

    final unreadMessages = messages.where((document) {
      final data = document.data();

      final senderId =
          data['senderId'] as String? ?? '';

      final isRead = data['isRead'] == true;

      return senderId.isNotEmpty &&
          senderId != userId &&
          !isRead &&
          document.reference.parent.parent?.id ==
              chatId;
    }).toList();

    if (unreadMessages.isEmpty) {
      return;
    }

    const batchSize = 400;

    for (var start = 0;
        start < unreadMessages.length;
        start += batchSize) {
      final end =
          (start + batchSize < unreadMessages.length)
              ? start + batchSize
              : unreadMessages.length;

      final batch = _firestore.batch();

      for (final document
          in unreadMessages.sublist(start, end)) {
        batch.update(
          document.reference,
          {'isRead': true},
        );
      }

      await batch.commit();
    }
  }

  /// Legacy method retained temporarily while
  /// updating the chat launcher.
  Future<String> getOrCreateChat({
    required String propertyId,
    required String propertyOwnerId,
  }) async {
    final businessOwnerId = currentUserId;
    final ownerId = propertyOwnerId.trim();
    final id = propertyId.trim();

    final chatId = buildChatId(
      propertyId: id,
      propertyOwnerId: ownerId,
    );

    final chatRef =
        _firestore.collection('chats').doc(chatId);

    final businessOwnerName =
        await _profileService.getCurrentUserName();

    if (businessOwnerName == null ||
        businessOwnerName.isEmpty) {
      throw StateError(
        'Business owner profile name is unavailable.',
      );
    }

    try {
      await chatRef.set({
        'propertyId': id,
        'businessOwnerId': businessOwnerId,
        'businessOwnerName': businessOwnerName,
        'propertyOwnerId': ownerId,
        'participantIds': [
          businessOwnerId,
          ownerId,
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt':
            FieldValue.serverTimestamp(),
        'lastMessageText': '',
      });
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }

      final existingChat = await chatRef.get();

      if (!existingChat.exists) {
        rethrow;
      }

      final data = existingChat.data();
      final participants = data?['participantIds'];

      if (data?['propertyId'] != id ||
          data?['businessOwnerId'] != businessOwnerId ||
          data?['propertyOwnerId'] != ownerId ||
          participants is! List ||
          !participants.contains(businessOwnerId) ||
          !participants.contains(ownerId)) {
        rethrow;
      }
    }

    return chatId;
  }
}