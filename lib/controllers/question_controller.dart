import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int> getQuestionCount(String sheetUrl) async {
  try {
    final response = await http.get(Uri.parse("$sheetUrl&action=getQuestions"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data?['success'] && data?['questions'] is List) {
        return data?['questions'].length;
      }
    }
  } catch (e) {
    print("Error fetching question count: $e");
  }
  return 0; // Default jika terjadi error atau tidak ada data
}