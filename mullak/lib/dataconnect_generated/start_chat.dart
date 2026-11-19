part of 'generated.dart';

class StartChatVariablesBuilder {
  String propertyOwnerId;

  final FirebaseDataConnect _dataConnect;
  StartChatVariablesBuilder(this._dataConnect, {required  this.propertyOwnerId,});
  Deserializer<StartChatData> dataDeserializer = (dynamic json)  => StartChatData.fromJson(jsonDecode(json));
  Serializer<StartChatVariables> varsSerializer = (StartChatVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<StartChatData, StartChatVariables>> execute() {
    return ref().execute();
  }

  MutationRef<StartChatData, StartChatVariables> ref() {
    StartChatVariables vars= StartChatVariables(propertyOwnerId: propertyOwnerId,);
    return _dataConnect.mutation("StartChat", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class StartChatChatInsert {
  final String id;
  StartChatChatInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final StartChatChatInsert otherTyped = other as StartChatChatInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  StartChatChatInsert({
    required this.id,
  });
}

@immutable
class StartChatData {
  final StartChatChatInsert chat_insert;
  StartChatData.fromJson(dynamic json):
  
  chat_insert = StartChatChatInsert.fromJson(json['chat_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final StartChatData otherTyped = other as StartChatData;
    return chat_insert == otherTyped.chat_insert;
    
  }
  @override
  int get hashCode => chat_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['chat_insert'] = chat_insert.toJson();
    return json;
  }

  StartChatData({
    required this.chat_insert,
  });
}

@immutable
class StartChatVariables {
  final String propertyOwnerId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  StartChatVariables.fromJson(Map<String, dynamic> json):
  
  propertyOwnerId = nativeFromJson<String>(json['propertyOwnerId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final StartChatVariables otherTyped = other as StartChatVariables;
    return propertyOwnerId == otherTyped.propertyOwnerId;
    
  }
  @override
  int get hashCode => propertyOwnerId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['propertyOwnerId'] = nativeToJson<String>(propertyOwnerId);
    return json;
  }

  StartChatVariables({
    required this.propertyOwnerId,
  });
}

