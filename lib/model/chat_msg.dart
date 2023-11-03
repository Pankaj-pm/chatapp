import 'dart:convert';

class ChatMsg {
  String? senderId;
  String? time;
  String? msg;
  bool? isRead;

  ChatMsg({
    this.senderId,
    this.time,
    this.msg,
    this.isRead,
  });

  factory ChatMsg.fromRawJson(String str) => ChatMsg.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatMsg.fromJson(Map<String, dynamic> json) => ChatMsg(
        senderId: json["sender_id"],
        time: json["time"],
        msg: json["msg"],
        isRead: json["is_read"],
      );

  Map<String, dynamic> toJson() => {
        "sender_id": senderId,
        "time": time,
        "msg": msg,
        "is_read": isRead,
      };
}
