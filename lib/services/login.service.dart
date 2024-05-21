


import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;

class LoginService {
  static Future<http.Response> loginAttempt(String username, String password) async {
    return await Api.post('/Authentication/Login', {
      "userName": username,
      "password": password,
      "keepMeLogin": true
    });
  }
}

