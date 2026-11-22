part of 'generated.dart';

class SavePropertyVariablesBuilder {
  String propertyId;

  final FirebaseDataConnect _dataConnect;
  SavePropertyVariablesBuilder(this._dataConnect, {required  this.propertyId,});
  Deserializer<SavePropertyData> dataDeserializer = (dynamic json)  => SavePropertyData.fromJson(jsonDecode(json));
  Serializer<SavePropertyVariables> varsSerializer = (SavePropertyVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<SavePropertyData, SavePropertyVariables>> execute() {
    return ref().execute();
  }

  MutationRef<SavePropertyData, SavePropertyVariables> ref() {
    SavePropertyVariables vars= SavePropertyVariables(propertyId: propertyId,);
    return _dataConnect.mutation("SaveProperty", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class SavePropertyUserUpdate {
  final String id;
  SavePropertyUserUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SavePropertyUserUpdate otherTyped = other as SavePropertyUserUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SavePropertyUserUpdate({
    required this.id,
  });
}

@immutable
class SavePropertyData {
  final SavePropertyUserUpdate? user_update;
  SavePropertyData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : SavePropertyUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SavePropertyData otherTyped = other as SavePropertyData;
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

  SavePropertyData({
    this.user_update,
  });
}

@immutable
class SavePropertyVariables {
  final String propertyId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SavePropertyVariables.fromJson(Map<String, dynamic> json):
  
  propertyId = nativeFromJson<String>(json['propertyId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SavePropertyVariables otherTyped = other as SavePropertyVariables;
    return propertyId == otherTyped.propertyId;
    
  }
  @override
  int get hashCode => propertyId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['propertyId'] = nativeToJson<String>(propertyId);
    return json;
  }

  SavePropertyVariables({
    required this.propertyId,
  });
}

