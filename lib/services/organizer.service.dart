
import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;

class OrganizerService {
  static Future<http.Response> myOrganizer() async {
    return await Api.get('/Organizer/My');
  }
}
