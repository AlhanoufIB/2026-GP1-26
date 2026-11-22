part of 'generated.dart';

class GetMySavedPropertyIdsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetMySavedPropertyIdsVariablesBuilder(this._dataConnect, );
  Deserializer<GetMySavedPropertyIdsData> dataDeserializer = (dynamic json)  => GetMySavedPropertyIdsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetMySavedPropertyIdsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetMySavedPropertyIdsData, void> ref() {
    
    return _dataConnect.query("GetMySavedPropertyIds", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetMySavedPropertyIdsUser {
  final List<String>? savedPropertyIds;
  GetMySavedPropertyIdsUser.fromJson(dynamic json):
  
  savedPropertyIds = json['savedPropertyIds'] == null ? null : (json['savedPropertyIds'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMySavedPropertyIdsUser otherTyped = other as GetMySavedPropertyIdsUser;
    return savedPropertyIds == otherTyped.savedPropertyIds;
    
  }
  @override
  int get hashCode => savedPropertyIds.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (savedPropertyIds != null) {
      json['savedPropertyIds'] = savedPropertyIds?.map((e) => nativeToJson<String>(e)).toList();
    }
    return json;
  }

  GetMySavedPropertyIdsUser({
    this.savedPropertyIds,
  });
}

@immutable
class GetMySavedPropertyIdsData {
  final GetMySavedPropertyIdsUser? user;
  GetMySavedPropertyIdsData.fromJson(dynamic json):
  
  user = json['user'] == null ? null : GetMySavedPropertyIdsUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMySavedPropertyIdsData otherTyped = other as GetMySavedPropertyIdsData;
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

  GetMySavedPropertyIdsData({
    this.user,
  });
}

