part of 'generated.dart';

class GetPropertyVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetPropertyVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetPropertyData> dataDeserializer = (dynamic json)  => GetPropertyData.fromJson(jsonDecode(json));
  Serializer<GetPropertyVariables> varsSerializer = (GetPropertyVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetPropertyData, GetPropertyVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetPropertyData, GetPropertyVariables> ref() {
    GetPropertyVariables vars= GetPropertyVariables(id: id,);
    return _dataConnect.query("GetProperty", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetPropertyProperty {
  final String id;
  final String title;
  final String district;
  final String city;
  final String propertyType;
  final String? activityType;
  final double areaSqm;
  final double rentPrice;
  final String status;
  final double latitude;
  final double longitude;
  final double? estimatedPrice;
  final String? address;
  final String? description;
  final bool? hasParking;
  final GetPropertyPropertyOwner owner;
  final List<GetPropertyPropertyImages> images;
  GetPropertyProperty.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  district = nativeFromJson<String>(json['district']),
  city = nativeFromJson<String>(json['city']),
  propertyType = nativeFromJson<String>(json['propertyType']),
  activityType = json['activityType'] == null ? null : nativeFromJson<String>(json['activityType']),
  areaSqm = nativeFromJson<double>(json['areaSqm']),
  rentPrice = nativeFromJson<double>(json['rentPrice']),
  status = nativeFromJson<String>(json['status']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']),
  estimatedPrice = json['estimatedPrice'] == null ? null : nativeFromJson<double>(json['estimatedPrice']),
  address = json['address'] == null ? null : nativeFromJson<String>(json['address']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  hasParking = json['hasParking'] == null ? null : nativeFromJson<bool>(json['hasParking']),
  owner = GetPropertyPropertyOwner.fromJson(json['owner']),
  images = (json['images'] as List<dynamic>)
        .map((e) => GetPropertyPropertyImages.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetPropertyProperty otherTyped = other as GetPropertyProperty;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    district == otherTyped.district && 
    city == otherTyped.city && 
    propertyType == otherTyped.propertyType && 
    activityType == otherTyped.activityType && 
    areaSqm == otherTyped.areaSqm && 
    rentPrice == otherTyped.rentPrice && 
    status == otherTyped.status && 
    latitude == otherTyped.latitude && 
    longitude == otherTyped.longitude && 
    estimatedPrice == otherTyped.estimatedPrice && 
    address == otherTyped.address && 
    description == otherTyped.description && 
    hasParking == otherTyped.hasParking && 
    owner == otherTyped.owner && 
    images == otherTyped.images;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, district.hashCode, city.hashCode, propertyType.hashCode, activityType.hashCode, areaSqm.hashCode, rentPrice.hashCode, status.hashCode, latitude.hashCode, longitude.hashCode, estimatedPrice.hashCode, address.hashCode, description.hashCode, hasParking.hashCode, owner.hashCode, images.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['district'] = nativeToJson<String>(district);
    json['city'] = nativeToJson<String>(city);
    json['propertyType'] = nativeToJson<String>(propertyType);
    if (activityType != null) {
      json['activityType'] = nativeToJson<String?>(activityType);
    }
    json['areaSqm'] = nativeToJson<double>(areaSqm);
    json['rentPrice'] = nativeToJson<double>(rentPrice);
    json['status'] = nativeToJson<String>(status);
    json['latitude'] = nativeToJson<double>(latitude);
    json['longitude'] = nativeToJson<double>(longitude);
    if (estimatedPrice != null) {
      json['estimatedPrice'] = nativeToJson<double?>(estimatedPrice);
    }
    if (address != null) {
      json['address'] = nativeToJson<String?>(address);
    }
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    if (hasParking != null) {
      json['hasParking'] = nativeToJson<bool?>(hasParking);
    }
    json['owner'] = owner.toJson();
    json['images'] = images.map((e) => e.toJson()).toList();
    return json;
  }

  GetPropertyProperty({
    required this.id,
    required this.title,
    required this.district,
    required this.city,
    required this.propertyType,
    this.activityType,
    required this.areaSqm,
    required this.rentPrice,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.estimatedPrice,
    this.address,
    this.description,
    this.hasParking,
    required this.owner,
    required this.images,
  });
}

@immutable
class GetPropertyPropertyOwner {
  final String id;
  final String fullName;
  GetPropertyPropertyOwner.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  fullName = nativeFromJson<String>(json['fullName']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetPropertyPropertyOwner otherTyped = other as GetPropertyPropertyOwner;
    return id == otherTyped.id && 
    fullName == otherTyped.fullName;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, fullName.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['fullName'] = nativeToJson<String>(fullName);
    return json;
  }

  GetPropertyPropertyOwner({
    required this.id,
    required this.fullName,
  });
}

@immutable
class GetPropertyPropertyImages {
  final String imageUrl;
  final int displayOrder;
  GetPropertyPropertyImages.fromJson(dynamic json):
  
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

    final GetPropertyPropertyImages otherTyped = other as GetPropertyPropertyImages;
    return imageUrl == otherTyped.imageUrl && 
    displayOrder == otherTyped.displayOrder;
    
  }
  @override
  int get hashCode => Object.hashAll([imageUrl.hashCode, displayOrder.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    json['displayOrder'] = nativeToJson<int>(displayOrder);
    return json;
  }

  GetPropertyPropertyImages({
    required this.imageUrl,
    required this.displayOrder,
  });
}

@immutable
class GetPropertyData {
  final GetPropertyProperty? property;
  GetPropertyData.fromJson(dynamic json):
  
  property = json['property'] == null ? null : GetPropertyProperty.fromJson(json['property']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetPropertyData otherTyped = other as GetPropertyData;
    return property == otherTyped.property;
    
  }
  @override
  int get hashCode => property.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (property != null) {
      json['property'] = property!.toJson();
    }
    return json;
  }

  GetPropertyData({
    this.property,
  });
}

@immutable
class GetPropertyVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetPropertyVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetPropertyVariables otherTyped = other as GetPropertyVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetPropertyVariables({
    required this.id,
  });
}

