import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpHelper {
  String baseUrl = "https://fcm.googleapis.com/";
  static HttpHelper instance = HttpHelper._();

  factory HttpHelper() {
    return instance;
  }

  HttpHelper._();

  Future<dynamic> getHttp(String endPoint) async {
    Uri uri = Uri.parse("$baseUrl$endPoint");
    http.Response future = await http.get(uri);
    return future.body;
  }

  Future<dynamic> postHttp(String endPoint, Map map) async {
    Uri uri = Uri.parse("$baseUrl$endPoint");
    print(uri);
    print(json.encode(map));

    http.Response future = await http.post(
      uri,
      body: json.encode(map),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':'key=AAAAdOdk3cA:APA91bGrh9QIvGfjYij8lJ77ks7C5NfqSFwleew7xes3wJy0ZD-LwfIJN_ON3vwUQk0-UYdfxDIQM9uk04GYGjFEKpKG7YikaMijrw7dfIlq9pGZzmsaWuBOVzP1V-xRHA7r8trwrc8I'
      }
    );
    return future.body;
  }
}
