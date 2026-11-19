part of 'generated.dart';

class AddPropertyImageVariablesBuilder {
  String propertyId;
  String imageUrl;
  int displayOrder;

  final FirebaseDataConnect _dataConnect;
  AddPropertyImageVariablesBuilder(this._dataConnect, {required  this.propertyId,required  this.imageUrl,required  this.displayOrder,});
  Deserializer<AddPropertyImageData> dataDeserializer = (dynamic json)  => AddPropertyImageData.fromJson(jsonDecode(json));
  Serializer<AddPropertyImageVariables> varsSerializer = (AddPropertyImageVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddPropertyImageData, AddPropertyImageVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddPropertyImageData, AddPropertyImageVariables> ref() {
    AddPropertyImageVariables vars= AddPropertyImageVariables(propertyId: propertyId,imageUrl: imageUrl,displayOrder: displayOrder,);
    return _dataConnect.mutation("AddPropertyImage", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddPropertyImageImageInsert {
  final String id;
  AddPropertyImageImageInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddPropertyImageImageInsert otherTyped = other as AddPropertyImageImageInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddPropertyImageImageInsert({
    required this.id,
  });
}

@immutable
class AddPropertyImageData {
  final AddPropertyImageImageInsert image_insert;
  AddPropertyImageData.fromJson(dynamic json):
  
  image_insert = AddPropertyImageImageInsert.fromJson(json['image_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddPropertyImageData otherTyped = other as AddPropertyImageData;
    return image_insert == otherTyped.image_insert;
    
  }
  @override
  int get hashCode => image_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['image_insert'] = image_insert.toJson();
    return json;
  }

  AddPropertyImageData({
    required this.image_insert,
  });
}

@immutable
class AddPropertyImageVariables {
  final String propertyId;
  final String imageUrl;
  final int displayOrder;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddPropertyImageVariables.fromJson(Map<String, dynamic> json):
  
  propertyId = nativeFromJson<String>(json['propertyId']),
  imageUrl = nativeFromJson<String>(json['imageUrl']),
  displayOrder = nativeFromJson<int>(json['displayOrder']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddPropertyImageVariables otherTyped = other as AddPropertyImageVariables;
    return propertyId == otherTyped.propertyId && 
    imageUrl == otherTyped.imageUrl && 
    displayOrder == otherTyped.displayOrder;
    
  }
  @override
  int get hashCode => Object.hashAll([propertyId.hashCode, imageUrl.hashCode, displayOrder.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['propertyId'] = nativeToJson<String>(propertyId);
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    json['displayOrder'] = nativeToJson<int>(displayOrder);
    return json;
  }

  AddPropertyImageVariables({
    required this.propertyId,
    required this.imageUrl,
    required this.displayOrder,
  });
}

