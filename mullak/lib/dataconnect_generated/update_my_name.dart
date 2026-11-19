part of 'generated.dart';

class UpdateMyNameVariablesBuilder {
  String fullName;

  final FirebaseDataConnect _dataConnect;
  UpdateMyNameVariablesBuilder(this._dataConnect, {required  this.fullName,});
  Deserializer<UpdateMyNameData> dataDeserializer = (dynamic json)  => UpdateMyNameData.fromJson(jsonDecode(json));
  Serializer<UpdateMyNameVariables> varsSerializer = (UpdateMyNameVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateMyNameData, UpdateMyNameVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateMyNameData, UpdateMyNameVariables> ref() {
    UpdateMyNameVariables vars= UpdateMyNameVariables(fullName: fullName,);
    return _dataConnect.mutation("UpdateMyName", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateMyNameUserUpdate {
  final String id;
  UpdateMyNameUserUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMyNameUserUpdate otherTyped = other as UpdateMyNameUserUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateMyNameUserUpdate({
    required this.id,
  });
}

@immutable
class UpdateMyNameData {
  final UpdateMyNameUserUpdate? user_update;
  UpdateMyNameData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UpdateMyNameUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMyNameData otherTyped = other as UpdateMyNameData;
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

  UpdateMyNameData({
    this.user_update,
  });
}

@immutable
class UpdateMyNameVariables {
  final String fullName;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateMyNameVariables.fromJson(Map<String, dynamic> json):
  
  fullName = nativeFromJson<String>(json['fullName']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMyNameVariables otherTyped = other as UpdateMyNameVariables;
    return fullName == otherTyped.fullName;
    
  }
  @override
  int get hashCode => fullName.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['fullName'] = nativeToJson<String>(fullName);
    return json;
  }

  UpdateMyNameVariables({
    required this.fullName,
  });
}

