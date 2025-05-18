
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MyHttpInterceptor {
  final http.Client _client;

  MyHttpInterceptor(this._client);

  Future<http.Response> post(Uri url, Object? body,) async {
    // Intercept the request before it's sent
    if (kDebugMode) {
      print('POST Request URL--> $url');

      print('POST Request Body--> ${body.toString()}');
    }

    // You can modify the request if needed
    // For example, you can add headers
    // if (headers != null) {
    //   headers['Authorization'] = 'Bearer token';
    // }

    // Send the modified request using the inner client
    return _client.post(url, body: body);
  }

// Add methods for other HTTP methods (e.g., post, put, delete) as needed
}