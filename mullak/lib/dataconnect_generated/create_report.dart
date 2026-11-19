part of 'generated.dart';

class CreateReportVariablesBuilder {
  String description;
  String reportType;

  final FirebaseDataConnect _dataConnect;
  CreateReportVariablesBuilder(this._dataConnect, {required  this.description,required  this.reportType,});
  Deserializer<CreateReportData> dataDeserializer = (dynamic json)  => CreateReportData.fromJson(jsonDecode(json));
  Serializer<CreateReportVariables> varsSerializer = (CreateReportVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateReportData, CreateReportVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateReportData, CreateReportVariables> ref() {
    CreateReportVariables vars= CreateReportVariables(description: description,reportType: reportType,);
    return _dataConnect.mutation("CreateReport", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateReportReportInsert {
  final String id;
  CreateReportReportInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReportReportInsert otherTyped = other as CreateReportReportInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateReportReportInsert({
    required this.id,
  });
}

@immutable
class CreateReportData {
  final CreateReportReportInsert report_insert;
  CreateReportData.fromJson(dynamic json):
  
  report_insert = CreateReportReportInsert.fromJson(json['report_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReportData otherTyped = other as CreateReportData;
    return report_insert == otherTyped.report_insert;
    
  }
  @override
  int get hashCode => report_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['report_insert'] = report_insert.toJson();
    return json;
  }

  CreateReportData({
    required this.report_insert,
  });
}

@immutable
class CreateReportVariables {
  final String description;
  final String reportType;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateReportVariables.fromJson(Map<String, dynamic> json):
  
  description = nativeFromJson<String>(json['description']),
  reportType = nativeFromJson<String>(json['reportType']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateReportVariables otherTyped = other as CreateReportVariables;
    return description == otherTyped.description && 
    reportType == otherTyped.reportType;
    
  }
  @override
  int get hashCode => Object.hashAll([description.hashCode, reportType.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['description'] = nativeToJson<String>(description);
    json['reportType'] = nativeToJson<String>(reportType);
    return json;
  }

  CreateReportVariables({
    required this.description,
    required this.reportType,
  });
}

