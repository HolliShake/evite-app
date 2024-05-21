

import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;

class TrackService {
  static Future<http.Response> getTracksByEventId(int eventId) async {
    return await Api.get('/Track/Event/$eventId');
  }
}

