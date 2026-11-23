part of 'generated.dart';

class DeleteMyPropertyImagesVariablesBuilder {
  String propertyId;

  final FirebaseDataConnect _dataConnect;
  DeleteMyPropertyImagesVariablesBuilder(this._dataConnect, {required  this.propertyId,});
  Deserializer<DeleteMyPropertyImagesData> dataDeserializer = (dynamic json)  => DeleteMyPropertyImagesData.fromJson(jsonDecode(json));
  Serializer<DeleteMyPropertyImagesVariables> varsSerializer = (DeleteMyPropertyImagesVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteMyPropertyImagesData, DeleteMyPropertyImagesVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteMyPropertyImagesData, DeleteMyPropertyImagesVariables> ref() {
    DeleteMyPropertyImagesVariables vars= DeleteMyPropertyImagesVariables(propertyId: propertyId,);
    return _dataConnect.mutation("DeleteMyPropertyImages", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteMyPropertyImagesData {
  final int image_deleteMany;
  DeleteMyPropertyImagesData.fromJson(dynamic json):
  
  image_deleteMany = nativeFromJson<int>(json['image_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteMyPropertyImagesData otherTyped = other as DeleteMyPropertyImagesData;
    return image_deleteMany == otherTyped.image_deleteMany;
    
  }
  @override
  int get hashCode => image_deleteMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['image_deleteMany'] = nativeToJson<int>(image_deleteMany);
    return json;
  }

  DeleteMyPropertyImagesData({
    required this.image_deleteMany,
  });
}

@immutable
class DeleteMyPropertyImagesVariables {
  final String propertyId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteMyPropertyImagesVariables.fromJson(Map<String, dynamic> json):
  
  propertyId = nativeFromJson<String>(json['propertyId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteMyPropertyImagesVariables otherTyped = other as DeleteMyPropertyImagesVariables;
    return propertyId == otherTyped.propertyId;
    
  }
  @override
  int get hashCode => propertyId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['propertyId'] = nativeToJson<String>(propertyId);
    return json;
  }

  DeleteMyPropertyImagesVariables({
    required this.propertyId,
  });
}

