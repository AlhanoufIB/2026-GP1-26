part of 'generated.dart';

class ListPropertiesByIdsVariablesBuilder {
  List<String> ids;

  final FirebaseDataConnect _dataConnect;
  ListPropertiesByIdsVariablesBuilder(this._dataConnect, {required  this.ids,});
  Deserializer<ListPropertiesByIdsData> dataDeserializer = (dynamic json)  => ListPropertiesByIdsData.fromJson(jsonDecode(json));
  Serializer<ListPropertiesByIdsVariables> varsSerializer = (ListPropertiesByIdsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListPropertiesByIdsData, ListPropertiesByIdsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListPropertiesByIdsData, ListPropertiesByIdsVariables> ref() {
    ListPropertiesByIdsVariables vars= ListPropertiesByIdsVariables(ids: ids,);
    return _dataConnect.query("ListPropertiesByIds", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListPropertiesByIdsProperties {
  final String id;
  final String title;
  final String district;
  final String city;
  final String propertyType;
  final double areaSqm;
  final double rentPrice;
  final String status;
  final double latitude;
  final double longitude;
  final double? estimatedPrice;
  final String? address;
  final String? description;
  final bool? hasParking;
  final ListPropertiesByIdsPropertiesOwner owner;
  final List<ListPropertiesByIdsPropertiesImages> images;
  ListPropertiesByIdsProperties.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  district = nativeFromJson<String>(json['district']),
  city = nativeFromJson<String>(json['city']),
  propertyType = nativeFromJson<String>(json['propertyType']),
  areaSqm = nativeFromJson<double>(json['areaSqm']),
  rentPrice = nativeFromJson<double>(json['rentPrice']),
  status = nativeFromJson<String>(json['status']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']),
  estimatedPrice = json['estimatedPrice'] == null ? null : nativeFromJson<double>(json['estimatedPrice']),
  address = json['address'] == null ? null : nativeFromJson<String>(json['address']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  hasParking = json['hasParking'] == null ? null : nativeFromJson<bool>(json['hasParking']),
  owner = ListPropertiesByIdsPropertiesOwner.fromJson(json['owner']),
  images = (json['images'] as List<dynamic>)
        .map((e) => ListPropertiesByIdsPropertiesImages.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListPropertiesByIdsProperties otherTyped = other as ListPropertiesByIdsProperties;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    district == otherTyped.district && 
    city == otherTyped.city && 
    propertyType == otherTyped.propertyType && 
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
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, district.hashCode, city.hashCode, propertyType.hashCode, areaSqm.hashCode, rentPrice.hashCode, status.hashCode, latitude.hashCode, longitude.hashCode, estimatedPrice.hashCode, address.hashCode, description.hashCode, hasParking.hashCode, owner.hashCode, images.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['district'] = nativeToJson<String>(district);
    json['city'] = nativeToJson<String>(city);
    json['propertyType'] = nativeToJson<String>(propertyType);
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

  ListPropertiesByIdsProperties({
    required this.id,
    required this.title,
    required this.district,
    required this.city,
    required this.propertyType,
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
class ListPropertiesByIdsPropertiesOwner {
  final String id;
  ListPropertiesByIdsPropertiesOwner.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListPropertiesByIdsPropertiesOwner otherTyped = other as ListPropertiesByIdsPropertiesOwner;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ListPropertiesByIdsPropertiesOwner({
    required this.id,
  });
}

@immutable
class ListPropertiesByIdsPropertiesImages {
  final String imageUrl;
  ListPropertiesByIdsPropertiesImages.fromJson(dynamic json):
  
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListPropertiesByIdsPropertiesImages otherTyped = other as ListPropertiesByIdsPropertiesImages;
    return imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => imageUrl.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  ListPropertiesByIdsPropertiesImages({
    required this.imageUrl,
  });
}

@immutable
class ListPropertiesByIdsData {
  final List<ListPropertiesByIdsProperties> properties;
  ListPropertiesByIdsData.fromJson(dynamic json):
  
  properties = (json['properties'] as List<dynamic>)
        .map((e) => ListPropertiesByIdsProperties.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListPropertiesByIdsData otherTyped = other as ListPropertiesByIdsData;
    return properties == otherTyped.properties;
    
  }
  @override
  int get hashCode => properties.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['properties'] = properties.map((e) => e.toJson()).toList();
    return json;
  }

  ListPropertiesByIdsData({
    required this.properties,
  });
}

@immutable
class ListPropertiesByIdsVariables {
  final List<String> ids;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListPropertiesByIdsVariables.fromJson(Map<String, dynamic> json):
  
  ids = (json['ids'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListPropertiesByIdsVariables otherTyped = other as ListPropertiesByIdsVariables;
    return ids == otherTyped.ids;
    
  }
  @override
  int get hashCode => ids.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['ids'] = ids.map((e) => nativeToJson<String>(e)).toList();
    return json;
  }

  ListPropertiesByIdsVariables({
    required this.ids,
  });
}

