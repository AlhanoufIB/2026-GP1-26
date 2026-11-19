part of 'generated.dart';

class UpsertUserVariablesBuilder {
  String fullName;
  String phoneNumber;
  bool bOwnerFlag;
  bool pOwnerFlag;

  final FirebaseDataConnect _dataConnect;
  UpsertUserVariablesBuilder(this._dataConnect, {required  this.fullName,required  this.phoneNumber,required  this.bOwnerFlag,required  this.pOwnerFlag,});
  Deserializer<UpsertUserData> dataDeserializer = (dynamic json)  => UpsertUserData.fromJson(jsonDecode(json));
  Serializer<UpsertUserVariables> varsSerializer = (UpsertUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertUserData, UpsertUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertUserData, UpsertUserVariables> ref() {
    UpsertUserVariables vars= UpsertUserVariables(fullName: fullName,phoneNumber: phoneNumber,bOwnerFlag: bOwnerFlag,pOwnerFlag: pOwnerFlag,);
    return _dataConnect.mutation("UpsertUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertUserUserUpsert {
  final String id;
  UpsertUserUserUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertUserUserUpsert otherTyped = other as UpsertUserUserUpsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpsertUserUserUpsert({
    required this.id,
  });
}

@immutable
class UpsertUserData {
  final UpsertUserUserUpsert user_upsert;
  UpsertUserData.fromJson(dynamic json):
  
  user_upsert = UpsertUserUserUpsert.fromJson(json['user_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertUserData otherTyped = other as UpsertUserData;
    return user_upsert == otherTyped.user_upsert;
    
  }
  @override
  int get hashCode => user_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_upsert'] = user_upsert.toJson();
    return json;
  }

  UpsertUserData({
    required this.user_upsert,
  });
}

@immutable
class UpsertUserVariables {
  final String fullName;
  final String phoneNumber;
  final bool bOwnerFlag;
  final bool pOwnerFlag;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertUserVariables.fromJson(Map<String, dynamic> json):
  
  fullName = nativeFromJson<String>(json['fullName']),
  phoneNumber = nativeFromJson<String>(json['phoneNumber']),
  bOwnerFlag = nativeFromJson<bool>(json['bOwnerFlag']),
  pOwnerFlag = nativeFromJson<bool>(json['pOwnerFlag']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertUserVariables otherTyped = other as UpsertUserVariables;
    return fullName == otherTyped.fullName && 
    phoneNumber == otherTyped.phoneNumber && 
    bOwnerFlag == otherTyped.bOwnerFlag && 
    pOwnerFlag == otherTyped.pOwnerFlag;
    
  }
  @override
  int get hashCode => Object.hashAll([fullName.hashCode, phoneNumber.hashCode, bOwnerFlag.hashCode, pOwnerFlag.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['fullName'] = nativeToJson<String>(fullName);
    json['phoneNumber'] = nativeToJson<String>(phoneNumber);
    json['bOwnerFlag'] = nativeToJson<bool>(bOwnerFlag);
    json['pOwnerFlag'] = nativeToJson<bool>(pOwnerFlag);
    return json;
  }

  UpsertUserVariables({
    required this.fullName,
    required this.phoneNumber,
    required this.bOwnerFlag,
    required this.pOwnerFlag,
  });
}

