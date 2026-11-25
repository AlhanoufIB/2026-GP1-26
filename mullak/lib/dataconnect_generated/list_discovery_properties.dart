part of 'generated.dart';

class ListDiscoveryPropertiesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListDiscoveryPropertiesVariablesBuilder(this._dataConnect, );
  Deserializer<ListDiscoveryPropertiesData> dataDeserializer = (dynamic json)  => ListDiscoveryPropertiesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListDiscoveryPropertiesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListDiscoveryPropertiesData, void> ref() {
    
    return _dataConnect.query("ListDiscoveryProperties", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListDiscoveryPropertiesProperties {
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
  final ListDiscoveryPropertiesPropertiesOwner owner;
  final List<ListDiscoveryPropertiesPropertiesImages> images;
  ListDiscoveryPropertiesProperties.fromJson(dynamic json):
  
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
  owner = ListDiscoveryPropertiesPropertiesOwner.fromJson(json['owner']),
  images = (json['images'] as List<dynamic>)
        .map((e) => ListDiscoveryPropertiesPropertiesImages.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListDiscoveryPropertiesProperties otherTyped = other as ListDiscoveryPropertiesProperties;
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

  ListDiscoveryPropertiesProperties({
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
class ListDiscoveryPropertiesPropertiesOwner {
  final String id;
  ListDiscoveryPropertiesPropertiesOwner.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListDiscoveryPropertiesPropertiesOwner otherTyped = other as ListDiscoveryPropertiesPropertiesOwner;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ListDiscoveryPropertiesPropertiesOwner({
    required this.id,
  });
}

@immutable
class ListDiscoveryPropertiesPropertiesImages {
  final String imageUrl;
  ListDiscoveryPropertiesPropertiesImages.fromJson(dynamic json):
  
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListDiscoveryPropertiesPropertiesImages otherTyped = other as ListDiscoveryPropertiesPropertiesImages;
    return imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => imageUrl.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  ListDiscoveryPropertiesPropertiesImages({
    required this.imageUrl,
  });
}

@immutable
class ListDiscoveryPropertiesData {
  final List<ListDiscoveryPropertiesProperties> properties;
  ListDiscoveryPropertiesData.fromJson(dynamic json):
  
  properties = (json['properties'] as List<dynamic>)
        .map((e) => ListDiscoveryPropertiesProperties.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListDiscoveryPropertiesData otherTyped = other as ListDiscoveryPropertiesData;
    return properties == otherTyped.properties;
    
  }
  @override
  int get hashCode => properties.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['properties'] = properties.map((e) => e.toJson()).toList();
    return json;
  }

  ListDiscoveryPropertiesData({
    required this.properties,
  });
}

