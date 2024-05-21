import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;


class EventService {
  static Future<http.Response> getEventsByOrganizerId(int organizerId) async {
    return await Api.get('/Event/Organizer/$organizerId');
  }
}

