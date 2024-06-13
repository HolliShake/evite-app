
import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;


class AttendanceService {
  static Future<http.Response> fetchAttendance(int agendaTopicId) async {
    return await Api.get('/Attendance/AgendaTopic/$agendaTopicId');
  }

  static Future<http.Response> addAttendance(int agendaTopicId, int eventParticipantId, int attendanceType, int type) async {
    return await Api.post('/Attendance/Add', {
      "eventParticipantId": eventParticipantId,
      "agendaTopicId": agendaTopicId,
      "attendanceTypeId": attendanceType,
      "type": type,
      "log": DateTime.now().toIso8601String()
    });
  }

  // Event Attendance 

  static Future<http.Response> fetchAttendanceType(int eventId) async {
    return await Api.get('/Attendance/Event/Type/$eventId');
  }

  static Future<http.Response> fetchAttendanceByEventAndType(int eventId, int attendanceTypeId) async {
    return await Api.get('/Attendance/Event/$eventId/$attendanceTypeId');
  }

  static Future<http.Response> fetchAttendanceByTopicAndAttendanceTypeId(int topicId, int attendanceTypeId) async {
    return await Api.get('/Attendance/AgendaTopic/$topicId/$attendanceTypeId');
  }

  static Future<http.Response> addEventAttendance(int eventParticipantId, int attendanceTypeId, int type) async {
    return await Api.post('/Attendance/Event/Add', {
      "eventParticipantId": eventParticipantId,
      "attendanceTypeId": attendanceTypeId,
      "type": type,
      "log": DateTime.now().toIso8601String()
    });
  }

  static Future<http.Response> fetchAttendanceTypeByTopicId(int topicId) async {
    return await Api.get('/AttendanceType/Topic/$topicId');
  }
}

