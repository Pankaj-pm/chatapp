// To parse this JSON data, do
//
//     final fcmModel = fcmModelFromJson(jsonString);

import 'dart:convert';

FcmModel fcmModelFromJson(String str) => FcmModel.fromJson(json.decode(str));

String fcmModelToJson(FcmModel data) => json.encode(data.toJson());

class FcmModel {
  String? to;
  Data? notification;
  Data? data;

  FcmModel({
    this.to,
    this.notification,
    this.data,
  });

  factory FcmModel.fromJson(Map<String, dynamic> json) => FcmModel(
    to: json["to"],
    notification: json["notification"] == null ? null : Data.fromJson(json["notification"]),
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "to": to,
    "notification": notification?.toJson(),
    "data": data?.toJson(),
  };
}

class Data {
  String? title;
  String? body;

  Data({
    this.title,
    this.body,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    title: json["title"],
    body: json["body"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "body": body,
  };
}
