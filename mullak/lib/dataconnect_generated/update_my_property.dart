part of 'generated.dart';

class UpdateMyPropertyVariablesBuilder {
  String id;
  String title;
  String district;
  String propertyType;
  Optional<String> _activityType = Optional.optional(nativeFromJson, nativeToJson);
  double areaSqm;
  double rentPrice;
  double latitude;
  double longitude;
  Optional<double> _estimatedPrice = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _address = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  Optional<bool> _hasParking = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  UpdateMyPropertyVariablesBuilder activityType(String? t) {
   _activityType.value = t;
   return this;
  }
  UpdateMyPropertyVariablesBuilder estimatedPrice(double? t) {
   _estimatedPrice.value = t;
   return this;
  }
  UpdateMyPropertyVariablesBuilder address(String? t) {
   _address.value = t;
   return this;
  }
  UpdateMyPropertyVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }
  UpdateMyPropertyVariablesBuilder hasParking(bool? t) {
   _hasParking.value = t;
   return this;
  }

  UpdateMyPropertyVariablesBuilder(this._dataConnect, {required  this.id,required  this.title,required  this.district,required  this.propertyType,required  this.areaSqm,required  this.rentPrice,required  this.latitude,required  this.longitude,});
  Deserializer<UpdateMyPropertyData> dataDeserializer = (dynamic json)  => UpdateMyPropertyData.fromJson(jsonDecode(json));
  Serializer<UpdateMyPropertyVariables> varsSerializer = (UpdateMyPropertyVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateMyPropertyData, UpdateMyPropertyVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateMyPropertyData, UpdateMyPropertyVariables> ref() {
    UpdateMyPropertyVariables vars= UpdateMyPropertyVariables(id: id,title: title,district: district,propertyType: propertyType,activityType: _activityType,areaSqm: areaSqm,rentPrice: rentPrice,latitude: latitude,longitude: longitude,estimatedPrice: _estimatedPrice,address: _address,description: _description,hasParking: _hasParking,);
    return _dataConnect.mutation("UpdateMyProperty", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateMyPropertyData {
  final int property_updateMany;
  UpdateMyPropertyData.fromJson(dynamic json):
  
  property_updateMany = nativeFromJson<int>(json['property_updateMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMyPropertyData otherTyped = other as UpdateMyPropertyData;
    return property_updateMany == otherTyped.property_updateMany;
    
  }
  @override
  int get hashCode => property_updateMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['property_updateMany'] = nativeToJson<int>(property_updateMany);
    return json;
  }

  UpdateMyPropertyData({
    required this.property_updateMany,
  });
}

@immutable
class UpdateMyPropertyVariables {
  final String id;
  final String title;
  final String district;
  final String propertyType;
  late final Optional<String>activityType;
  final double areaSqm;
  final double rentPrice;
  final double latitude;
  final double longitude;
  late final Optional<double>estimatedPrice;
  late final Optional<String>address;
  late final Optional<String>description;
  late final Optional<bool>hasParking;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateMyPropertyVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  district = nativeFromJson<String>(json['district']),
  propertyType = nativeFromJson<String>(json['propertyType']),
  areaSqm = nativeFromJson<double>(json['areaSqm']),
  rentPrice = nativeFromJson<double>(json['rentPrice']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']) {
  
  
  
  
  
  
    activityType = Optional.optional(nativeFromJson, nativeToJson);
    activityType.value = json['activityType'] == null ? null : nativeFromJson<String>(json['activityType']);
  
  
  
  
  
  
    estimatedPrice = Optional.optional(nativeFromJson, nativeToJson);
    estimatedPrice.value = json['estimatedPrice'] == null ? null : nativeFromJson<double>(json['estimatedPrice']);
  
  
    address = Optional.optional(nativeFromJson, nativeToJson);
    address.value = json['address'] == null ? null : nativeFromJson<String>(json['address']);
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  
    hasParking = Optional.optional(nativeFromJson, nativeToJson);
    hasParking.value = json['hasParking'] == null ? null : nativeFromJson<bool>(json['hasParking']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMyPropertyVariables otherTyped = other as UpdateMyPropertyVariables;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    district == otherTyped.district && 
    propertyType == otherTyped.propertyType && 
    activityType == otherTyped.activityType && 
    areaSqm == otherTyped.areaSqm && 
    rentPrice == otherTyped.rentPrice && 
    latitude == otherTyped.latitude && 
    longitude == otherTyped.longitude && 
    estimatedPrice == otherTyped.estimatedPrice && 
    address == otherTyped.address && 
    description == otherTyped.description && 
    hasParking == otherTyped.hasParking;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, district.hashCode, propertyType.hashCode, activityType.hashCode, areaSqm.hashCode, rentPrice.hashCode, latitude.hashCode, longitude.hashCode, estimatedPrice.hashCode, address.hashCode, description.hashCode, hasParking.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['district'] = nativeToJson<String>(district);
    json['propertyType'] = nativeToJson<String>(propertyType);
    if(activityType.state == OptionalState.set) {
      json['activityType'] = activityType.toJson();
    }
    json['areaSqm'] = nativeToJson<double>(areaSqm);
    json['rentPrice'] = nativeToJson<double>(rentPrice);
    json['latitude'] = nativeToJson<double>(latitude);
    json['longitude'] = nativeToJson<double>(longitude);
    if(estimatedPrice.state == OptionalState.set) {
      json['estimatedPrice'] = estimatedPrice.toJson();
    }
    if(address.state == OptionalState.set) {
      json['address'] = address.toJson();
    }
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    if(hasParking.state == OptionalState.set) {
      json['hasParking'] = hasParking.toJson();
    }
    return json;
  }

  UpdateMyPropertyVariables({
    required this.id,
    required this.title,
    required this.district,
    required this.propertyType,
    required this.activityType,
    required this.areaSqm,
    required this.rentPrice,
    required this.latitude,
    required this.longitude,
    required this.estimatedPrice,
    required this.address,
    required this.description,
    required this.hasParking,
  });
}

