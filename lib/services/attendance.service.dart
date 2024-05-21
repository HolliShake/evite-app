
import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;


class AttendanceService {
  static Future<http.Response> submitAttendance(int type, int profileId, int agendaTopicId) async {
    return await Api.post('/Attendance/Add', {
      "profileId": profileId,
      "agendaTopicId": agendaTopicId,
      "type": type,
      "log": "2024-05-21T07:44:26.139Z"
    });
  }
}

