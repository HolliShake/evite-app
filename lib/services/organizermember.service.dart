
import 'package:evitecompanion/services/api.dart';
import 'package:http/http.dart' as http;

class OrganizerMemberService {
  static Future<http.Response> myParentOrganizer() async {
    return await Api.get('/OrganizerMember/Organizers/My');
  }
}
