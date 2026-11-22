part of 'generated.dart';

class ListMyPropertiesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMyPropertiesVariablesBuilder(this._dataConnect, );
  Deserializer<ListMyPropertiesData> dataDeserializer = (dynamic json)  => ListMyPropertiesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMyPropertiesData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListMyPropertiesData, void> ref() {
    
    return _dataConnect.query("ListMyProperties", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMyPropertiesProperties {
  final String id;
  final String title;
  final String status;
  final double rentPrice;
  final String? address;
  final List<ListMyPropertiesPropertiesMyCoverImage> myCoverImage;
  ListMyPropertiesProperties.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  status = nativeFromJson<String>(json['status']),
  rentPrice = nativeFromJson<double>(json['rentPrice']),
  address = json['address'] == null ? null : nativeFromJson<String>(json['address']),
  myCoverImage = (json['myCoverImage'] as List<dynamic>)
        .map((e) => ListMyPropertiesPropertiesMyCoverImage.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyPropertiesProperties otherTyped = other as ListMyPropertiesProperties;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    status == otherTyped.status && 
    rentPrice == otherTyped.rentPrice && 
    address == otherTyped.address && 
    myCoverImage == otherTyped.myCoverImage;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, status.hashCode, rentPrice.hashCode, address.hashCode, myCoverImage.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['status'] = nativeToJson<String>(status);
    json['rentPrice'] = nativeToJson<double>(rentPrice);
    if (address != null) {
      json['address'] = nativeToJson<String?>(address);
    }
    json['myCoverImage'] = myCoverImage.map((e) => e.toJson()).toList();
    return json;
  }

  ListMyPropertiesProperties({
    required this.id,
    required this.title,
    required this.status,
    required this.rentPrice,
    this.address,
    required this.myCoverImage,
  });
}

@immutable
class ListMyPropertiesPropertiesMyCoverImage {
  final String imageUrl;
  ListMyPropertiesPropertiesMyCoverImage.fromJson(dynamic json):
  
  imageUrl = nativeFromJson<String>(json['imageUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyPropertiesPropertiesMyCoverImage otherTyped = other as ListMyPropertiesPropertiesMyCoverImage;
    return imageUrl == otherTyped.imageUrl;
    
  }
  @override
  int get hashCode => imageUrl.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['imageUrl'] = nativeToJson<String>(imageUrl);
    return json;
  }

  ListMyPropertiesPropertiesMyCoverImage({
    required this.imageUrl,
  });
}

@immutable
class ListMyPropertiesData {
  final List<ListMyPropertiesProperties> properties;
  ListMyPropertiesData.fromJson(dynamic json):
  
  properties = (json['properties'] as List<dynamic>)
        .map((e) => ListMyPropertiesProperties.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyPropertiesData otherTyped = other as ListMyPropertiesData;
    return properties == otherTyped.properties;
    
  }
  @override
  int get hashCode => properties.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['properties'] = properties.map((e) => e.toJson()).toList();
    return json;
  }

  ListMyPropertiesData({
    required this.properties,
  });
}

