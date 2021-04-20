import 'dart:convert';

GetDevices getDevicesFromJson(String str) => GetDevices.fromJson(json.decode(str));

String getDevicesToJson(GetDevices data) => json.encode(data.toJson());

class GetDevices {
  GetDevices({
    this.pageNo,
    this.pageSize,
    this.totalElements,
    this.totalPages,
    this.data,
  });

  int pageNo;
  int pageSize;
  int totalElements;
  int totalPages;
  List<Datum> data;

  factory GetDevices.fromJson(Map<String, dynamic> json) => GetDevices(
    pageNo: json["pageNo"],
    pageSize: json["pageSize"],
    totalElements: json["totalElements"],
    totalPages: json["totalPages"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pageNo": pageNo,
    "pageSize": pageSize,
    "totalElements": totalElements,
    "totalPages": totalPages,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.id,
    this.name,
    this.tags,
    this.description,
    this.clientId,
    this.securityKey,
    this.apiKey,
    this.latitude,
    this.longitude,
    this.model,
    this.manufacturer,
    this.firmwareVersion,
    this.hardwareVersion,
    this.serialNumber,
    this.mac,
    this.imei,
    this.imsi,
    this.sim,
    this.isPublic,
    this.isActive,
    this.type,
    this.image,
    this.createdBy,
    this.updatedBy,
    this.projectId,
    this.deviceTemplateId,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.deviceTemplate,
  });

  int id;
  String name;
  String tags;
  String description;
  String clientId;
  String securityKey;
  String apiKey;
  double latitude;
  double longitude;
  String model;
  String manufacturer;
  String firmwareVersion;
  String hardwareVersion;
  String serialNumber;
  String mac;
  String imei;
  String imsi;
  String sim;
  bool isPublic;
  bool isActive;
  int type;
  dynamic image;
  String createdBy;
  String updatedBy;
  int projectId;
  int deviceTemplateId;
  int tenantId;
  DateTime createdAt;
  DateTime updatedAt;
  DeviceTemplate deviceTemplate;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    tags: json["tags"] == null ? null : json["tags"],
    description: json["description"] == null ? null : json["description"],
    clientId: json["clientId"],
    securityKey: json["securityKey"],
    apiKey: json["apiKey"],
    latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
    longitude: json["longitude"] == null ? null : json["longitude"].toDouble(),
    model: json["model"] == null ? null : json["model"],
    manufacturer: json["manufacturer"] == null ? null : json["manufacturer"],
    firmwareVersion: json["firmwareVersion"] == null ? null : json["firmwareVersion"],
    hardwareVersion: json["hardwareVersion"] == null ? null : json["hardwareVersion"],
    serialNumber: json["serialNumber"] == null ? null : json["serialNumber"],
    mac: json["mac"] == null ? null : json["mac"],
    imei: json["imei"] == null ? null : json["imei"],
    imsi: json["imsi"] == null ? null : json["imsi"],
    sim: json["sim"] == null ? null : json["sim"],
    isPublic: json["isPublic"],
    isActive: json["isActive"],
    type: json["type"],
    image: json["image"],
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"],
    projectId: json["projectId"],
    deviceTemplateId: json["deviceTemplateId"],
    tenantId: json["tenantId"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    deviceTemplate: DeviceTemplate.fromJson(json["deviceTemplate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "tags": tags == null ? null : tags,
    "description": description == null ? null : description,
    "clientId": clientId,
    "securityKey": securityKey,
    "apiKey": apiKey,
    "latitude": latitude == null ? null : latitude,
    "longitude": longitude == null ? null : longitude,
    "model": model == null ? null : model,
    "manufacturer": manufacturer == null ? null : manufacturer,
    "firmwareVersion": firmwareVersion == null ? null : firmwareVersion,
    "hardwareVersion": hardwareVersion == null ? null : hardwareVersion,
    "serialNumber": serialNumber == null ? null : serialNumber,
    "mac": mac == null ? null : mac,
    "imei": imei == null ? null : imei,
    "imsi": imsi == null ? null : imsi,
    "sim": sim == null ? null : sim,
    "isPublic": isPublic,
    "isActive": isActive,
    "type": type,
    "image": image,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "projectId": projectId,
    "deviceTemplateId": deviceTemplateId,
    "tenantId": tenantId,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "deviceTemplate": deviceTemplate.toJson(),
  };
}

class DeviceTemplate {
  DeviceTemplate({
    this.id,
    this.name,
    this.tags,
    this.description,
    this.createdBy,
    this.updatedBy,
    this.projectId,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String name;
  String tags;
  String description;
  String createdBy;
  String updatedBy;
  int projectId;
  int tenantId;
  DateTime createdAt;
  DateTime updatedAt;

  factory DeviceTemplate.fromJson(Map<String, dynamic> json) => DeviceTemplate(
    id: json["id"],
    name: json["name"],
    tags: json["tags"],
    description: json["description"],
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"],
    projectId: json["projectId"],
    tenantId: json["tenantId"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "tags": tags,
    "description": description,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "projectId": projectId,
    "tenantId": tenantId,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
