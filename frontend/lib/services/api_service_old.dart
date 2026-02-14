import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // FOR CODESPACE: Update this to your forwarded port 8000 URL
  // Go to PORTS tab → Find port 8000 → Copy the URL
  // Example: 'https://your-codespace-8000.app.github.dev'
  
  static const String baseUrl = 'https://verbose-space-waffle-r4gv66q46ww52xr5w-8000.app.github.dev/';
  
  // If above doesn't work, try these alternatives:
  // - 'http://127.0.0.1:8000'
  // - Your Codespace forwarded URL from PORTS tab

  static Future<Map<String, dynamic>> assessPatient(
      Map<String, dynamic> data) async {
    
    print('🔵 Sending request to: $baseUrl/assess');
    print('📤 Data: $data');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assess'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Backend returned ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      return result;
      
    } catch (e) {
      print('❌ Error occurred: $e');
      
      // Provide helpful error message
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused')) {
        throw Exception(
          'Cannot connect to backend. Please ensure:\n'
          '1. Backend is running (python main.py)\n'
          '2. Port 8000 is accessible\n'
          '3. Update baseUrl in api_service.dart if needed'
        );
      }
      
      throw Exception('Connection error: $e');
    }
  }
}