import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;


class ReleaseService {
  static Future<http.Response> getReleaseTypesByAgendaTopicId(int topicId) async {
    return await Api.get('/ReleaseType/AgendaTopic/$topicId');
  }

  static Future<http.Response> addRelease(int releaseTypeId, int participantId) async {
    return await Api.post('/ReleaseType/Add', {
      "releaseTypeId": releaseTypeId,
      "participantId": participantId,
    });
  }

  static Future<http.Response> fetchRelease(int releaseTypeId) async {
    return await Api.get('/Release/ReleaseType/$releaseTypeId');
  }
}
