import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; // Android emulator

  static Future<Map<String, dynamic>> reportIncident(String description, {String reporterName = 'Guest'}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/report"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"description": description, "reporter_name": reporterName}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  static Future<void> updateStatus(String id, String status) async {
    final response = await http.post(
      Uri.parse("$baseUrl/incident/$id/status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Status update failed');
    }
  }

  static Future<void> submitFeedback({
    required String incidentId,
    required int rating,
    required String comment,
    required bool responseAdequate,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/incident/$incidentId/feedback"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "incident_id": incidentId,
        "rating": rating,
        "comment": comment,
        "response_adequate": responseAdequate,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Feedback submission failed');
    }
  }
}