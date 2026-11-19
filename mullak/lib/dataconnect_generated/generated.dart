library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'upsert_user.dart';

part 'get_my_profile.dart';

part 'update_my_name.dart';

part 'create_report.dart';

part 'create_review.dart';

part 'create_property.dart';

part 'update_my_property_status.dart';

part 'add_property_image.dart';

part 'list_available_properties.dart';

part 'list_my_properties.dart';

part 'get_property.dart';

part 'start_chat.dart';

part 'list_my_chats.dart';

part 'send_message.dart';

part 'list_messages.dart';







class MullakConnector {
  
  
  UpsertUserVariablesBuilder upsertUser ({required String fullName, required String phoneNumber, required bool bOwnerFlag, required bool pOwnerFlag, }) {
    return UpsertUserVariablesBuilder(dataConnect, fullName: fullName,phoneNumber: phoneNumber,bOwnerFlag: bOwnerFlag,pOwnerFlag: pOwnerFlag,);
  }
  
  
  GetMyProfileVariablesBuilder getMyProfile () {
    return GetMyProfileVariablesBuilder(dataConnect, );
  }
  
  
  UpdateMyNameVariablesBuilder updateMyName ({required String fullName, }) {
    return UpdateMyNameVariablesBuilder(dataConnect, fullName: fullName,);
  }
  
  
  CreateReportVariablesBuilder createReport ({required String description, required String reportType, }) {
    return CreateReportVariablesBuilder(dataConnect, description: description,reportType: reportType,);
  }
  
  
  CreateReviewVariablesBuilder createReview ({required int rating, }) {
    return CreateReviewVariablesBuilder(dataConnect, rating: rating,);
  }
  
  
  CreatePropertyVariablesBuilder createProperty ({required String title, required String district, required String city, required String propertyType, required double areaSqm, required double rentPrice, required double latitude, required double longitude, }) {
    return CreatePropertyVariablesBuilder(dataConnect, title: title,district: district,city: city,propertyType: propertyType,areaSqm: areaSqm,rentPrice: rentPrice,latitude: latitude,longitude: longitude,);
  }
  
  
  UpdateMyPropertyStatusVariablesBuilder updateMyPropertyStatus ({required String id, required String status, }) {
    return UpdateMyPropertyStatusVariablesBuilder(dataConnect, id: id,status: status,);
  }
  
  
  AddPropertyImageVariablesBuilder addPropertyImage ({required String propertyId, required String imageUrl, required int displayOrder, }) {
    return AddPropertyImageVariablesBuilder(dataConnect, propertyId: propertyId,imageUrl: imageUrl,displayOrder: displayOrder,);
  }
  
  
  ListAvailablePropertiesVariablesBuilder listAvailableProperties () {
    return ListAvailablePropertiesVariablesBuilder(dataConnect, );
  }
  
  
  ListMyPropertiesVariablesBuilder listMyProperties () {
    return ListMyPropertiesVariablesBuilder(dataConnect, );
  }
  
  
  GetPropertyVariablesBuilder getProperty ({required String id, }) {
    return GetPropertyVariablesBuilder(dataConnect, id: id,);
  }
  
  
  StartChatVariablesBuilder startChat ({required String propertyOwnerId, }) {
    return StartChatVariablesBuilder(dataConnect, propertyOwnerId: propertyOwnerId,);
  }
  
  
  ListMyChatsVariablesBuilder listMyChats () {
    return ListMyChatsVariablesBuilder(dataConnect, );
  }
  
  
  SendMessageVariablesBuilder sendMessage ({required String chatId, required String content, }) {
    return SendMessageVariablesBuilder(dataConnect, chatId: chatId,content: content,);
  }
  
  
  ListMessagesVariablesBuilder listMessages ({required String chatId, }) {
    return ListMessagesVariablesBuilder(dataConnect, chatId: chatId,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'europe-west1',
    'mullak',
    'mullak',
  );

  MullakConnector({required this.dataConnect});
  static MullakConnector get instance {
    
    CacheSettings cacheSettings = CacheSettings(
      maxAge: Duration(milliseconds:0),
      storage: CacheStorage.persistent,
    );
    
    return MullakConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            cacheSettings: cacheSettings,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
