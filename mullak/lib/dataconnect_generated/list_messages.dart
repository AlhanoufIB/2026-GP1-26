part of 'generated.dart';

class ListMessagesVariablesBuilder {
  String chatId;

  final FirebaseDataConnect _dataConnect;
  ListMessagesVariablesBuilder(this._dataConnect, {required  this.chatId,});
  Deserializer<ListMessagesData> dataDeserializer = (dynamic json)  => ListMessagesData.fromJson(jsonDecode(json));
  Serializer<ListMessagesVariables> varsSerializer = (ListMessagesVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListMessagesData, ListMessagesVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListMessagesData, ListMessagesVariables> ref() {
    ListMessagesVariables vars= ListMessagesVariables(chatId: chatId,);
    return _dataConnect.query("ListMessages", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListMessagesMessages {
  final String id;
  final String content;
  final bool isRead;
  final Timestamp sentAt;
  final ListMessagesMessagesSender sender;
  ListMessagesMessages.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  content = nativeFromJson<String>(json['content']),
  isRead = nativeFromJson<bool>(json['isRead']),
  sentAt = Timestamp.fromJson(json['sentAt']),
  sender = ListMessagesMessagesSender.fromJson(json['sender']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesMessages otherTyped = other as ListMessagesMessages;
    return id == otherTyped.id && 
    content == otherTyped.content && 
    isRead == otherTyped.isRead && 
    sentAt == otherTyped.sentAt && 
    sender == otherTyped.sender;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, content.hashCode, isRead.hashCode, sentAt.hashCode, sender.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['content'] = nativeToJson<String>(content);
    json['isRead'] = nativeToJson<bool>(isRead);
    json['sentAt'] = sentAt.toJson();
    json['sender'] = sender.toJson();
    return json;
  }

  ListMessagesMessages({
    required this.id,
    required this.content,
    required this.isRead,
    required this.sentAt,
    required this.sender,
  });
}

@immutable
class ListMessagesMessagesSender {
  final String id;
  final String fullName;
  ListMessagesMessagesSender.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  fullName = nativeFromJson<String>(json['fullName']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesMessagesSender otherTyped = other as ListMessagesMessagesSender;
    return id == otherTyped.id && 
    fullName == otherTyped.fullName;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, fullName.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['fullName'] = nativeToJson<String>(fullName);
    return json;
  }

  ListMessagesMessagesSender({
    required this.id,
    required this.fullName,
  });
}

@immutable
class ListMessagesData {
  final List<ListMessagesMessages> messages;
  ListMessagesData.fromJson(dynamic json):
  
  messages = (json['messages'] as List<dynamic>)
        .map((e) => ListMessagesMessages.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesData otherTyped = other as ListMessagesData;
    return messages == otherTyped.messages;
    
  }
  @override
  int get hashCode => messages.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['messages'] = messages.map((e) => e.toJson()).toList();
    return json;
  }

  ListMessagesData({
    required this.messages,
  });
}

@immutable
class ListMessagesVariables {
  final String chatId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListMessagesVariables.fromJson(Map<String, dynamic> json):
  
  chatId = nativeFromJson<String>(json['chatId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesVariables otherTyped = other as ListMessagesVariables;
    return chatId == otherTyped.chatId;
    
  }
  @override
  int get hashCode => chatId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['chatId'] = nativeToJson<String>(chatId);
    return json;
  }

  ListMessagesVariables({
    required this.chatId,
  });
}

