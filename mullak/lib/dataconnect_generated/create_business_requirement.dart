part of 'generated.dart';

class CreateBusinessRequirementVariablesBuilder {
  String businessType;
  double budget;
  double requiredSpace;
  Optional<String> _preferredLocation = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateBusinessRequirementVariablesBuilder preferredLocation(String? t) {
   _preferredLocation.value = t;
   return this;
  }

  CreateBusinessRequirementVariablesBuilder(this._dataConnect, {required  this.businessType,required  this.budget,required  this.requiredSpace,});
  Deserializer<CreateBusinessRequirementData> dataDeserializer = (dynamic json)  => CreateBusinessRequirementData.fromJson(jsonDecode(json));
  Serializer<CreateBusinessRequirementVariables> varsSerializer = (CreateBusinessRequirementVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateBusinessRequirementData, CreateBusinessRequirementVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateBusinessRequirementData, CreateBusinessRequirementVariables> ref() {
    CreateBusinessRequirementVariables vars= CreateBusinessRequirementVariables(businessType: businessType,budget: budget,requiredSpace: requiredSpace,preferredLocation: _preferredLocation,);
    return _dataConnect.mutation("CreateBusinessRequirement", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateBusinessRequirementBusinessRequirementInsert {
  final String id;
  CreateBusinessRequirementBusinessRequirementInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateBusinessRequirementBusinessRequirementInsert otherTyped = other as CreateBusinessRequirementBusinessRequirementInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateBusinessRequirementBusinessRequirementInsert({
    required this.id,
  });
}

@immutable
class CreateBusinessRequirementData {
  final CreateBusinessRequirementBusinessRequirementInsert businessRequirement_insert;
  CreateBusinessRequirementData.fromJson(dynamic json):
  
  businessRequirement_insert = CreateBusinessRequirementBusinessRequirementInsert.fromJson(json['businessRequirement_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateBusinessRequirementData otherTyped = other as CreateBusinessRequirementData;
    return businessRequirement_insert == otherTyped.businessRequirement_insert;
    
  }
  @override
  int get hashCode => businessRequirement_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['businessRequirement_insert'] = businessRequirement_insert.toJson();
    return json;
  }

  CreateBusinessRequirementData({
    required this.businessRequirement_insert,
  });
}

@immutable
class CreateBusinessRequirementVariables {
  final String businessType;
  final double budget;
  final double requiredSpace;
  late final Optional<String>preferredLocation;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateBusinessRequirementVariables.fromJson(Map<String, dynamic> json):
  
  businessType = nativeFromJson<String>(json['businessType']),
  budget = nativeFromJson<double>(json['budget']),
  requiredSpace = nativeFromJson<double>(json['requiredSpace']) {
  
  
  
  
  
    preferredLocation = Optional.optional(nativeFromJson, nativeToJson);
    preferredLocation.value = json['preferredLocation'] == null ? null : nativeFromJson<String>(json['preferredLocation']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateBusinessRequirementVariables otherTyped = other as CreateBusinessRequirementVariables;
    return businessType == otherTyped.businessType && 
    budget == otherTyped.budget && 
    requiredSpace == otherTyped.requiredSpace && 
    preferredLocation == otherTyped.preferredLocation;
    
  }
  @override
  int get hashCode => Object.hashAll([businessType.hashCode, budget.hashCode, requiredSpace.hashCode, preferredLocation.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['businessType'] = nativeToJson<String>(businessType);
    json['budget'] = nativeToJson<double>(budget);
    json['requiredSpace'] = nativeToJson<double>(requiredSpace);
    if(preferredLocation.state == OptionalState.set) {
      json['preferredLocation'] = preferredLocation.toJson();
    }
    return json;
  }

  CreateBusinessRequirementVariables({
    required this.businessType,
    required this.budget,
    required this.requiredSpace,
    required this.preferredLocation,
  });
}

