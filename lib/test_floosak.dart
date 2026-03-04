import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Try to login to get a token
  final url = Uri.parse('https://wallets-workshop.dev-options.com/api/login');
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email': 'test@new.com', // Need a valid user
      'password': 'password123',
    }),
  );
  
  String? token;
  if (response.statusCode == 200) {
    token = json.decode(response.body)['data']['token'];
    print("Token: $token");
  } else {
    print("Login failed: ${response.body}");
    return;
  }

  // Now try Floosak Purchase
  final pUrl = Uri.parse('https://wallets-workshop.dev-options.com/api/purchase');
  final pRes = await http.post(
    pUrl,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'wallet': 'floosak',
      'amount': 100.0,
      'code': '123456',
      'items': jsonEncode([
        {'id': 1, 'name': 'Test', 'quantity': 1, 'price': 100.0}
      ])
    }),
  );
  
  print("Purchase status: ${pRes.statusCode}");
  print("Purchase body: ${pRes.body}");
}
