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

  /// Get an existing chat or create a new one.
  ///
  /// The chat ID is deterministic, so the same
  /// property and users share one conversation.
  Future<String> getOrCreateChat({
    required String propertyId,
    required String propertyOwnerId,
  }) async {
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

    final chatId =
        '${id}_${businessOwnerId}_$ownerId';

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
      // Try to create the chat directly.
      // This avoids reading a nonexistent document,
      // which can be denied by Firestore rules.
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

      // If the document already exists, the rules
      // reject replacing it. Check whether it is
      // the expected conversation instead.
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