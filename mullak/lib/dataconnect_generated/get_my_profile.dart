part of 'generated.dart';

class GetMyProfileVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetMyProfileVariablesBuilder(this._dataConnect, );
  Deserializer<GetMyProfileData> dataDeserializer = (dynamic json)  => GetMyProfileData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetMyProfileData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetMyProfileData, void> ref() {
    
    return _dataConnect.query("GetMyProfile", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetMyProfileUser {
  final String id;
  final String fullName;
  final String phoneNumber;
  final bool bOwnerFlag;
  final bool pOwnerFlag;
  GetMyProfileUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
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

    final GetMyProfileUser otherTyped = other as GetMyProfileUser;
    return id == otherTyped.id && 
    fullName == otherTyped.fullName && 
    phoneNumber == otherTyped.phoneNumber && 
    bOwnerFlag == otherTyped.bOwnerFlag && 
    pOwnerFlag == otherTyped.pOwnerFlag;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, fullName.hashCode, phoneNumber.hashCode, bOwnerFlag.hashCode, pOwnerFlag.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['fullName'] = nativeToJson<String>(fullName);
    json['phoneNumber'] = nativeToJson<String>(phoneNumber);
    json['bOwnerFlag'] = nativeToJson<bool>(bOwnerFlag);
    json['pOwnerFlag'] = nativeToJson<bool>(pOwnerFlag);
    return json;
  }

  GetMyProfileUser({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.bOwnerFlag,
    required this.pOwnerFlag,
  });
}

@immutable
class GetMyProfileData {
  final GetMyProfileUser? user;
  GetMyProfileData.fromJson(dynamic json):
  
  user = json['user'] == null ? null : GetMyProfileUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMyProfileData otherTyped = other as GetMyProfileData;
    return user == otherTyped.user;
    
  }
  @override
  int get hashCode => user.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return json;
  }

  GetMyProfileData({
    this.user,
  });
}

