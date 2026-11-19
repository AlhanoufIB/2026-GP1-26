part of 'generated.dart';

class CreateReviewVariablesBuilder {
  int rating;
  Optional<String> _comment = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateReviewVariablesBuilder comment(String? t) {
   _comment.value = t;
   return this;
  }

  CreateReviewVariablesBuilder(this._dataConnect, {required  this.rating,});
  Deserializer<CreateReviewData> dataDeserializer = (dynamic json)  => CreateReviewData.fromJson(jsonDecode(json));
  Serializer<CreateReviewVariables> varsSerializer = (CreateReviewVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateReviewData, CreateReviewVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateReviewData, CreateReviewVariables> ref() {
    CreateReviewVariables vars= CreateReviewVariables(rating: rating,comment: _comment,);
    return _dataConnect.mutation("CreateReview", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateReviewReviewInsert {
  final String id;
  CreateReviewReviewInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReviewReviewInsert otherTyped = other as CreateReviewReviewInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateReviewReviewInsert({
    required this.id,
  });
}

@immutable
class CreateReviewData {
  final CreateReviewReviewInsert review_insert;
  CreateReviewData.fromJson(dynamic json):
  
  review_insert = CreateReviewReviewInsert.fromJson(json['review_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReviewData otherTyped = other as CreateReviewData;
    return review_insert == otherTyped.review_insert;
    
  }
  @override
  int get hashCode => review_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['review_insert'] = review_insert.toJson();
    return json;
  }

  CreateReviewData({
    required this.review_insert,
  });
}

@immutable
class CreateReviewVariables {
  final int rating;
  late final Optional<String>comment;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateReviewVariables.fromJson(Map<String, dynamic> json):
  
  rating = nativeFromJson<int>(json['rating']) {
  
  
  
    comment = Optional.optional(nativeFromJson, nativeToJson);
    comment.value = json['comment'] == null ? null : nativeFromJson<String>(json['comment']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReviewVariables otherTyped = other as CreateReviewVariables;
    return rating == otherTyped.rating && 
    comment == otherTyped.comment;
    
  }
  @override
  int get hashCode => Object.hashAll([rating.hashCode, comment.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['rating'] = nativeToJson<int>(rating);
    if(comment.state == OptionalState.set) {
      json['comment'] = comment.toJson();
    }
    return json;
  }

  CreateReviewVariables({
    required this.rating,
    required this.comment,
  });
}

