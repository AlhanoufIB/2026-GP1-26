part of 'generated.dart';

class UnsavePropertyVariablesBuilder {
  String propertyId;

  final FirebaseDataConnect _dataConnect;
  UnsavePropertyVariablesBuilder(this._dataConnect, {required  this.propertyId,});
  Deserializer<UnsavePropertyData> dataDeserializer = (dynamic json)  => UnsavePropertyData.fromJson(jsonDecode(json));
  Serializer<UnsavePropertyVariables> varsSerializer = (UnsavePropertyVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UnsavePropertyData, UnsavePropertyVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UnsavePropertyData, UnsavePropertyVariables> ref() {
    UnsavePropertyVariables vars= UnsavePropertyVariables(propertyId: propertyId,);
    return _dataConnect.mutation("UnsaveProperty", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UnsavePropertyUserUpdate {
  final String id;
  UnsavePropertyUserUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UnsavePropertyUserUpdate otherTyped = other as UnsavePropertyUserUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UnsavePropertyUserUpdate({
    required this.id,
  });
}

@immutable
class UnsavePropertyData {
  final UnsavePropertyUserUpdate? user_update;
  UnsavePropertyData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UnsavePropertyUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UnsavePropertyData otherTyped = other as UnsavePropertyData;
    return user_update == otherTyped.user_update;
    
  }
  @override
  int get hashCode => user_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    return json;
  }

  UnsavePropertyData({
    this.user_update,
  });
}

@immutable
class UnsavePropertyVariables {
  final String propertyId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UnsavePropertyVariables.fromJson(Map<String, dynamic> json):
  
  propertyId = nativeFromJson<String>(json['propertyId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UnsavePropertyVariables otherTyped = other as UnsavePropertyVariables;
    return propertyId == otherTyped.propertyId;
    
  }
  @override
  int get hashCode => propertyId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['propertyId'] = nativeToJson<String>(propertyId);
    return json;
  }

  UnsavePropertyVariables({
    required this.propertyId,
  });
}

