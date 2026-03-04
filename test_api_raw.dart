import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://wallets-workshop.dev-options.com/api/register');
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': 'API Test',
      'email': 'apitest_${DateTime.now().millisecondsSinceEpoch}@example.com',
      'mobile': '777999888',
      'password': 'password123',
      'password_confirmation': 'password123',
    }),
  );

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
