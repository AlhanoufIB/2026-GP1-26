import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../models/property.dart';
import '../screens/chat/chat_details_screen.dart';
import 'chat_firestore_service.dart';
import 'chat_property_service.dart';

class ChatLauncher {
  ChatLauncher._();

  static Future<void> openFromProperty({
    required BuildContext context,
    required Property property,
    String? ownerName,
  }) async {
    try {
      final chatService = ChatFirestoreService.instance;
      final propertyService = ChatPropertyService.instance;

      // Load the actual property and owner from Data Connect.
      final propertyInfo = await propertyService.getProperty(
        property.propertyId,
      );

      if (propertyInfo == null) {
        throw StateError(
          'Property not found in Data Connect.',
        );
      }

      final realProperty = propertyInfo.property;
      final realOwnerId = realProperty.ownerId;

      if (realOwnerId == chatService.currentUserId) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لا يمكنك بدء محادثة مع نفسك.',
            ),
          ),
        );
        return;
      }

      // Create or retrieve the Firestore conversation.
      final chatId = await chatService.getOrCreateChat(
        propertyId: realProperty.propertyId,
        propertyOwnerId: realOwnerId,
      );

      if (!context.mounted) return;

      final realOwnerName = propertyInfo.ownerName.trim();

      final conversation = ChatConversation(
        chatId: chatId,
        businessOwnerId: chatService.currentUserId,
        property: realProperty,
        ownerName: realOwnerName.isNotEmpty
            ? realOwnerName
            : 'مالك العقار',
        lastTime: 'الآن',
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatDetailsScreen(
            conversation: conversation,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Open chat error: $error');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح المحادثة. تأكدي أن العقار موجود في قاعدة البيانات الحقيقية.',
          ),
        ),
      );
    }
  }
}