part of 'generated.dart';

class ListMyChatsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMyChatsVariablesBuilder(this._dataConnect, );
  Deserializer<ListMyChatsData> dataDeserializer = (dynamic json)  => ListMyChatsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMyChatsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListMyChatsData, void> ref() {
    
    return _dataConnect.query("ListMyChats", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMyChatsChats {
  final String id;
  final ListMyChatsChatsBusinessOwner businessOwner;
  final ListMyChatsChatsPropertyOwner propertyOwner;
  ListMyChatsChats.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  businessOwner = ListMyChatsChatsBusinessOwner.fromJson(json['businessOwner']),
  propertyOwner = ListMyChatsChatsPropertyOwner.fromJson(json['propertyOwner']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyChatsChats otherTyped = other as ListMyChatsChats;
    return id == otherTyped.id && 
    businessOwner == otherTyped.businessOwner && 
    propertyOwner == otherTyped.propertyOwner;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, businessOwner.hashCode, propertyOwner.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['businessOwner'] = businessOwner.toJson();
    json['propertyOwner'] = propertyOwner.toJson();
    return json;
  }

  ListMyChatsChats({
    required this.id,
    required this.businessOwner,
    required this.propertyOwner,
  });
}

@immutable
class ListMyChatsChatsBusinessOwner {
  final String id;
  final String fullName;
  ListMyChatsChatsBusinessOwner.fromJson(dynamic json):
  
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

    final ListMyChatsChatsBusinessOwner otherTyped = other as ListMyChatsChatsBusinessOwner;
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

  ListMyChatsChatsBusinessOwner({
    required this.id,
    required this.fullName,
  });
}

@immutable
class ListMyChatsChatsPropertyOwner {
  final String id;
  final String fullName;
  ListMyChatsChatsPropertyOwner.fromJson(dynamic json):
  
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

    final ListMyChatsChatsPropertyOwner otherTyped = other as ListMyChatsChatsPropertyOwner;
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

  ListMyChatsChatsPropertyOwner({
    required this.id,
    required this.fullName,
  });
}

@immutable
class ListMyChatsData {
  final List<ListMyChatsChats> chats;
  ListMyChatsData.fromJson(dynamic json):
  
  chats = (json['chats'] as List<dynamic>)
        .map((e) => ListMyChatsChats.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyChatsData otherTyped = other as ListMyChatsData;
    return chats == otherTyped.chats;
    
  }
  @override
  int get hashCode => chats.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['chats'] = chats.map((e) => e.toJson()).toList();
    return json;
  }

  ListMyChatsData({
    required this.chats,
  });
}

