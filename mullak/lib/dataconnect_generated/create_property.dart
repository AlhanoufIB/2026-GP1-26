part of 'generated.dart';

class CreatePropertyVariablesBuilder {
  String title;
  String district;
  String city;
  String propertyType;
  double areaSqm;
  double rentPrice;
  double latitude;
  double longitude;

  final FirebaseDataConnect _dataConnect;
  CreatePropertyVariablesBuilder(this._dataConnect, {required  this.title,required  this.district,required  this.city,required  this.propertyType,required  this.areaSqm,required  this.rentPrice,required  this.latitude,required  this.longitude,});
  Deserializer<CreatePropertyData> dataDeserializer = (dynamic json)  => CreatePropertyData.fromJson(jsonDecode(json));
  Serializer<CreatePropertyVariables> varsSerializer = (CreatePropertyVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreatePropertyData, CreatePropertyVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreatePropertyData, CreatePropertyVariables> ref() {
    CreatePropertyVariables vars= CreatePropertyVariables(title: title,district: district,city: city,propertyType: propertyType,areaSqm: areaSqm,rentPrice: rentPrice,latitude: latitude,longitude: longitude,);
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
  final double areaSqm;
  final double rentPrice;
  final double latitude;
  final double longitude;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreatePropertyVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  district = nativeFromJson<String>(json['district']),
  city = nativeFromJson<String>(json['city']),
  propertyType = nativeFromJson<String>(json['propertyType']),
  areaSqm = nativeFromJson<double>(json['areaSqm']),
  rentPrice = nativeFromJson<double>(json['rentPrice']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']);
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
    areaSqm == otherTyped.areaSqm && 
    rentPrice == otherTyped.rentPrice && 
    latitude == otherTyped.latitude && 
    longitude == otherTyped.longitude;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, district.hashCode, city.hashCode, propertyType.hashCode, areaSqm.hashCode, rentPrice.hashCode, latitude.hashCode, longitude.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['district'] = nativeToJson<String>(district);
    json['city'] = nativeToJson<String>(city);
    json['propertyType'] = nativeToJson<String>(propertyType);
    json['areaSqm'] = nativeToJson<double>(areaSqm);
    json['rentPrice'] = nativeToJson<double>(rentPrice);
    json['latitude'] = nativeToJson<double>(latitude);
    json['longitude'] = nativeToJson<double>(longitude);
    return json;
  }

  CreatePropertyVariables({
    required this.title,
    required this.district,
    required this.city,
    required this.propertyType,
    required this.areaSqm,
    required this.rentPrice,
    required this.latitude,
    required this.longitude,
  });
}

