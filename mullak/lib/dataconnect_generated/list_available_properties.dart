part of 'generated.dart';

class ListAvailablePropertiesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListAvailablePropertiesVariablesBuilder(this._dataConnect, );
  Deserializer<ListAvailablePropertiesData> dataDeserializer = (dynamic json)  => ListAvailablePropertiesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListAvailablePropertiesData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListAvailablePropertiesData, void> ref() {
    
    return _dataConnect.query("ListAvailableProperties", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListAvailablePropertiesProperties {
  final String id;
  final String title;
  final String district;
  final String city;
  final String propertyType;
  final double areaSqm;
  final double rentPrice;
  final double latitude;
  final double longitude;
  final String? address;
  final List<ListAvailablePropertiesPropertiesCoverImage> coverImage;
  ListAvailablePropertiesProperties.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  district = nativeFromJson<String>(json['district']),
  city = nativeFromJson<String>(json['city']),
  propertyType = nativeFromJson<String>(json['propertyType']),
  areaSqm = nativeFromJson<double>(json['areaSqm']),
  rentPrice = nativeFromJson<double>(json['rentPrice']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']),
  address = json['address'] == null ? null : nativeFromJson<String>(json['address']),
  coverImage = (json['coverImage'] as List<dynamic>)
        .map((e) => ListAvailablePropertiesPropertiesCoverImage.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAvailablePropertiesProperties otherTyped = other as ListAvailablePropertiesProperties;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    district == otherTyped.district && 
    city == otherTyped.city && 
    propertyType == otherTyped.propertyType && 
    areaSqm == otherTyped.areaSqm && 
    rentPrice == otherTyped.rentPrice && 
    latitude == otherTyped.latitude && 
    longitude == otherTyped.longitude && 
    address == otherTyped.address && 
    coverImage == otherTyped.coverImage;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, district.hashCode, city.hashCode, propertyType.hashCode, areaSqm.hashCode, rentPrice.hashCode, latitude.hashCode, longitude.hashCode, address.hashCode, coverImage.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['district'] = nativeToJson<String>(district);
    json['city'] = nativeToJson<String>(city);
    json['propertyType'] = nativeToJson<String>(propertyType);
    json['areaSqm'] = nativeToJson<double>(areaSqm);
    json['rentPrice'] = nativeToJson<double>(rentPrice);
    json['latitude'] = nativeToJson<double>(latitude);
    json['longitude'] = nativeToJson<double>(longitude);
    if (address != null) {
      json['address'] = nativeToJson<String?>(address);
    }
    json['coverImage'] = coverImage.map((e) => e.toJson()).toList();
    return json;
  }

  ListAvailablePropertiesProperties({
    required this.id,
    required this.title,
    required this.district,
    required this.city,
    required this.propertyType,
    required this.areaSqm,
    required this.rentPrice,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.coverImage,
  });
}

@immutable
class ListAvailablePropertiesPropertiesCoverImage {
  final String imageUrl;
  ListAvailablePropertiesPropertiesCoverImage.fromJson(dynamic json):
  
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAvailablePropertiesPropertiesCoverImage otherTyped = other as ListAvailablePropertiesPropertiesCoverImage;
    return imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => imageUrl.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  ListAvailablePropertiesPropertiesCoverImage({
    required this.imageUrl,
  });
}

@immutable
class ListAvailablePropertiesData {
  final List<ListAvailablePropertiesProperties> properties;
  ListAvailablePropertiesData.fromJson(dynamic json):
  
  properties = (json['properties'] as List<dynamic>)
        .map((e) => ListAvailablePropertiesProperties.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAvailablePropertiesData otherTyped = other as ListAvailablePropertiesData;
    return properties == otherTyped.properties;
    
  }
  @override
  int get hashCode => properties.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['properties'] = properties.map((e) => e.toJson()).toList();
    return json;
  }

  ListAvailablePropertiesData({
    required this.properties,
  });
}

