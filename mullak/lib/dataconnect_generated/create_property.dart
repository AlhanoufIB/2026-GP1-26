part of 'generated.dart';

class CreatePropertyVariablesBuilder {
  String title;
  String district;
  String city;
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

  final FirebaseDataConnect _dataConnect;  CreatePropertyVariablesBuilder activityType(String? t) {
   _activityType.value = t;
   return this;
  }
  CreatePropertyVariablesBuilder estimatedPrice(double? t) {
   _estimatedPrice.value = t;
   return this;
  }
  CreatePropertyVariablesBuilder address(String? t) {
   _address.value = t;
   return this;
  }
  CreatePropertyVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }
  CreatePropertyVariablesBuilder hasParking(bool? t) {
   _hasParking.value = t;
   return this;
  }

  CreatePropertyVariablesBuilder(this._dataConnect, {required  this.title,required  this.district,required  this.city,required  this.propertyType,required  this.areaSqm,required  this.rentPrice,required  this.latitude,required  this.longitude,});
  Deserializer<CreatePropertyData> dataDeserializer = (dynamic json)  => CreatePropertyData.fromJson(jsonDecode(json));
  Serializer<CreatePropertyVariables> varsSerializer = (CreatePropertyVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreatePropertyData, CreatePropertyVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreatePropertyData, CreatePropertyVariables> ref() {
    CreatePropertyVariables vars= CreatePropertyVariables(title: title,district: district,city: city,propertyType: propertyType,activityType: _activityType,areaSqm: areaSqm,rentPrice: rentPrice,latitude: latitude,longitude: longitude,estimatedPrice: _estimatedPrice,address: _address,description: _description,hasParking: _hasParking,);
    return _dataConnect.mutation("CreateProperty", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreatePropertyPropertyInsert {
  final String id;
  CreatePropertyPropertyInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreatePropertyPropertyInsert otherTyped = other as CreatePropertyPropertyInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreatePropertyPropertyInsert({
    required this.id,
  });
}

@immutable
class CreatePropertyData {
  final CreatePropertyPropertyInsert property_insert;
  CreatePropertyData.fromJson(dynamic json):
  
  property_insert = CreatePropertyPropertyInsert.fromJson(json['property_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreatePropertyData otherTyped = other as CreatePropertyData;
    return property_insert == otherTyped.property_insert;
    
  }
  @override
  int get hashCode => property_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['property_insert'] = property_insert.toJson();
    return json;
  }

  CreatePropertyData({
    required this.property_insert,
  });
}

@immutable
class CreatePropertyVariables {
  final String title;
  final String district;
  final String city;
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
  CreatePropertyVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  district = nativeFromJson<String>(json['district']),
  city = nativeFromJson<String>(json['city']),
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

    final CreatePropertyVariables otherTyped = other as CreatePropertyVariables;
    return title == otherTyped.title && 
    district == otherTyped.district && 
    city == otherTyped.city && 
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
  int get hashCode => Object.hashAll([title.hashCode, district.hashCode, city.hashCode, propertyType.hashCode, activityType.hashCode, areaSqm.hashCode, rentPrice.hashCode, latitude.hashCode, longitude.hashCode, estimatedPrice.hashCode, address.hashCode, description.hashCode, hasParking.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['district'] = nativeToJson<String>(district);
    json['city'] = nativeToJson<String>(city);
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

  CreatePropertyVariables({
    required this.title,
    required this.district,
    required this.city,
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

