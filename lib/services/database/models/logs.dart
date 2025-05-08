import 'dart:convert';

Log logFromJson(String str) {
  final jsonData = json.decode(str);
  return Log.fromJson(jsonData);
}

String logToJson(Log data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Log {
  int id;
  int createDateTimeUnix;
  String logText;

  Log({
    required this.id,
    required this.createDateTimeUnix,
    required this.logText
  });

  factory Log.fromJson(Map<String, dynamic> json) => new Log(
    id: json["id"],
    createDateTimeUnix: json["create_date_time_unix"],
    logText: json["log_text"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_date_time_unix": createDateTimeUnix,
    "log_text": logText
  };
}