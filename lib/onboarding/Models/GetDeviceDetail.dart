import 'dart:convert';

List<GetDeviceDetail> getDeviceDetailFromJson(String str) => List<GetDeviceDetail>.from(json.decode(str).map((x) => GetDeviceDetail.fromJson(x)));

String getDeviceDetailToJson(List<GetDeviceDetail> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDeviceDetail {
  GetDeviceDetail({
    this.timestamp,
    this.result,
  });

  DateTime timestamp;
  Result result;

  factory GetDeviceDetail.fromJson(Map<String, dynamic> json) => GetDeviceDetail(
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
    result: json["result"] == null ? null : Result.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "timestamp": timestamp == null ? null : timestamp.toIso8601String(),
    "result": result == null ? null : result.toJson(),
  };
}

class Result {
  Result({
    this.avg,
  });

  double avg;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    avg: json["AVG"] == null ? null : json["AVG"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "AVG": avg == null ? null : avg,
  };
}
