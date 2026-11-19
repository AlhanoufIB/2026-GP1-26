part of 'generated.dart';

class UpdateMyPropertyStatusVariablesBuilder {
  String id;
  String status;

  final FirebaseDataConnect _dataConnect;
  UpdateMyPropertyStatusVariablesBuilder(this._dataConnect, {required  this.id,required  this.status,});
  Deserializer<UpdateMyPropertyStatusData> dataDeserializer = (dynamic json)  => UpdateMyPropertyStatusData.fromJson(jsonDecode(json));
  Serializer<UpdateMyPropertyStatusVariables> varsSerializer = (UpdateMyPropertyStatusVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateMyPropertyStatusData, UpdateMyPropertyStatusVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateMyPropertyStatusData, UpdateMyPropertyStatusVariables> ref() {
    UpdateMyPropertyStatusVariables vars= UpdateMyPropertyStatusVariables(id: id,status: status,);
    return _dataConnect.mutation("UpdateMyPropertyStatus", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateMyPropertyStatusData {
  final int property_updateMany;
  UpdateMyPropertyStatusData.fromJson(dynamic json):
  
  property_updateMany = nativeFromJson<int>(json['property_updateMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMyPropertyStatusData otherTyped = other as UpdateMyPropertyStatusData;
    return property_updateMany == otherTyped.property_updateMany;
    
  }
  @override
  int get hashCode => property_updateMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['property_updateMany'] = nativeToJson<int>(property_updateMany);
    return json;
  }

  UpdateMyPropertyStatusData({
    required this.property_updateMany,
  });
}

@immutable
class UpdateMyPropertyStatusVariables {
  final String id;
  final String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateMyPropertyStatusVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMyPropertyStatusVariables otherTyped = other as UpdateMyPropertyStatusVariables;
    return id == otherTyped.id && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  UpdateMyPropertyStatusVariables({
    required this.id,
    required this.status,
  });
}

