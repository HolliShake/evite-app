
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class Api {
  static const String apiUrl = 'https://evitepro-api.ustp.edu.ph/api';

  static Map<String, String> getConfig() {
    var accessToken = localStorage.getItem('accessToken');
      accessToken ??= '';
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken',
    };
  }
  
  static Future<http.Response> get(String endPoint) async {
    return await http.get(Uri.parse(apiUrl + endPoint), headers: getConfig());
  }

  static Future<http.Response> post(String endPoint, Map<String, dynamic> payload) async {
    return await http.post(Uri.parse(apiUrl + endPoint), body: json.encode(payload), headers: getConfig(), encoding: Encoding.getByName('utf-8'));
  }

  static Future<http.Response> put(String endPoint, Map<String, dynamic> payload) async {
    return await http.put(Uri.parse(apiUrl + endPoint), body: json.encode(payload), headers: getConfig());
  }

  static Future<http.Response> patch(String endPoint, Map<String, dynamic> payload) async {
    return await http.patch(Uri.parse(apiUrl + endPoint), body: json.encode(payload), headers: getConfig());
  }

  static Future<http.Response> delete(String endPoint) async {
    return await http.delete(Uri.parse(apiUrl + endPoint), headers: getConfig());
  }
}



