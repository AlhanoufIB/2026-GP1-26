part of 'generated.dart';

class DeleteMyPropertyVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteMyPropertyVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeleteMyPropertyData> dataDeserializer = (dynamic json)  => DeleteMyPropertyData.fromJson(jsonDecode(json));
  Serializer<DeleteMyPropertyVariables> varsSerializer = (DeleteMyPropertyVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteMyPropertyData, DeleteMyPropertyVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteMyPropertyData, DeleteMyPropertyVariables> ref() {
    DeleteMyPropertyVariables vars= DeleteMyPropertyVariables(id: id,);
    return _dataConnect.mutation("DeleteMyProperty", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteMyPropertyData {
  final int property_deleteMany;
  DeleteMyPropertyData.fromJson(dynamic json):
  
  property_deleteMany = nativeFromJson<int>(json['property_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteMyPropertyData otherTyped = other as DeleteMyPropertyData;
    return property_deleteMany == otherTyped.property_deleteMany;
    
  }
  @override
  int get hashCode => property_deleteMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['property_deleteMany'] = nativeToJson<int>(property_deleteMany);
    return json;
  }

  DeleteMyPropertyData({
    required this.property_deleteMany,
  });
}

@immutable
class DeleteMyPropertyVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteMyPropertyVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteMyPropertyVariables otherTyped = other as DeleteMyPropertyVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteMyPropertyVariables({
    required this.id,
  });
}

