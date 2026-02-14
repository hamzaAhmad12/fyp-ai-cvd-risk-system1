import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://verbose-space-waffle-r4gv66q46ww52xr5w-8000.app.github.dev';

  static Future<Map<String, dynamic>> assessPatient(
      Map<String, dynamic> data) async {
    
    final url = '$baseUrl/assess';
    print('🔵 Calling API: $url');
    print('📤 Request data: $data');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to connect to backend: $e');
    }
  }
}
