part of 'generated.dart';

class CreateRecommendationVariablesBuilder {
  String requirementId;
  String propertyId;
  double locationScore;
  double propertyMatchScore;
  String explanation;
  int rank;

  final FirebaseDataConnect _dataConnect;
  CreateRecommendationVariablesBuilder(this._dataConnect, {required  this.requirementId,required  this.propertyId,required  this.locationScore,required  this.propertyMatchScore,required  this.explanation,required  this.rank,});
  Deserializer<CreateRecommendationData> dataDeserializer = (dynamic json)  => CreateRecommendationData.fromJson(jsonDecode(json));
  Serializer<CreateRecommendationVariables> varsSerializer = (CreateRecommendationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateRecommendationData, CreateRecommendationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateRecommendationData, CreateRecommendationVariables> ref() {
    CreateRecommendationVariables vars= CreateRecommendationVariables(requirementId: requirementId,propertyId: propertyId,locationScore: locationScore,propertyMatchScore: propertyMatchScore,explanation: explanation,rank: rank,);
    return _dataConnect.mutation("CreateRecommendation", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateRecommendationRecommendationInsert {
  final String id;
  CreateRecommendationRecommendationInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateRecommendationRecommendationInsert otherTyped = other as CreateRecommendationRecommendationInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateRecommendationRecommendationInsert({
    required this.id,
  });
}

@immutable
class CreateRecommendationData {
  final CreateRecommendationRecommendationInsert recommendation_insert;
  CreateRecommendationData.fromJson(dynamic json):
  
  recommendation_insert = CreateRecommendationRecommendationInsert.fromJson(json['recommendation_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateRecommendationData otherTyped = other as CreateRecommendationData;
    return recommendation_insert == otherTyped.recommendation_insert;
    
  }
  @override
  int get hashCode => recommendation_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['recommendation_insert'] = recommendation_insert.toJson();
    return json;
  }

  CreateRecommendationData({
    required this.recommendation_insert,
  });
}

@immutable
class CreateRecommendationVariables {
  final String requirementId;
  final String propertyId;
  final double locationScore;
  final double propertyMatchScore;
  final String explanation;
  final int rank;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateRecommendationVariables.fromJson(Map<String, dynamic> json):
  
  requirementId = nativeFromJson<String>(json['requirementId']),
  propertyId = nativeFromJson<String>(json['propertyId']),
  locationScore = nativeFromJson<double>(json['locationScore']),
  propertyMatchScore = nativeFromJson<double>(json['propertyMatchScore']),
  explanation = nativeFromJson<String>(json['explanation']),
  rank = nativeFromJson<int>(json['rank']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateRecommendationVariables otherTyped = other as CreateRecommendationVariables;
    return requirementId == otherTyped.requirementId && 
    propertyId == otherTyped.propertyId && 
    locationScore == otherTyped.locationScore && 
    propertyMatchScore == otherTyped.propertyMatchScore && 
    explanation == otherTyped.explanation && 
    rank == otherTyped.rank;
    
  }
  @override
  int get hashCode => Object.hashAll([requirementId.hashCode, propertyId.hashCode, locationScore.hashCode, propertyMatchScore.hashCode, explanation.hashCode, rank.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['requirementId'] = nativeToJson<String>(requirementId);
    json['propertyId'] = nativeToJson<String>(propertyId);
    json['locationScore'] = nativeToJson<double>(locationScore);
    json['propertyMatchScore'] = nativeToJson<double>(propertyMatchScore);
    json['explanation'] = nativeToJson<String>(explanation);
    json['rank'] = nativeToJson<int>(rank);
    return json;
  }

  CreateRecommendationVariables({
    required this.requirementId,
    required this.propertyId,
    required this.locationScore,
    required this.propertyMatchScore,
    required this.explanation,
    required this.rank,
  });
}

