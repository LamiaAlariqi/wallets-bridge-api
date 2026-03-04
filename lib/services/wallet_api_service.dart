import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletApiService {
  static const String baseUrl = 'https://wallets-workshop.dev-options.com/api';

  Future<String?> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['data']?['token']?.toString();
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['data']?['token']?.toString();
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<bool> jaibPurchase({
    required String token,
    required double amount,
    String? code,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('$baseUrl/purchase');
    final String itemsJsonString = jsonEncode(items);

    final Map<String, dynamic> requestBody = {
      'wallet': 'jaib',
      'amount': amount,
      'items': itemsJsonString,
    };

    if (code != null && code.isNotEmpty) {
      requestBody['code'] = code;
    }

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['isSuccess'] == true;
    } else {
      throw Exception('Jaib Purchase failed: ${response.body}');
    }
  }

  Future<String?> floosakInitiatePurchase({
    required String token,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('$baseUrl/purchase');
    final String itemsJsonString = jsonEncode(items);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'wallet': 'floosak',
        'amount': amount,
        'items': itemsJsonString,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['isSuccess'] == true) {
        return data['data']?['wallet_reference_id']?.toString();
      } else {
        throw Exception('Floosak Purchase failed: ${response.body}');
      }
    } else {
      throw Exception('Floosak Purchase failed: ${response.body}');
    }
  }

  Future<bool> floosakConfirmOtp({
    required String token,
    required String referenceId,
    required String otp,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('$baseUrl/purchase/confirm-otp');
    final String itemsJsonString = jsonEncode(items);

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'wallet_reference_id': referenceId,
        'otp': otp,
        'items': itemsJsonString,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['isSuccess'] == true;
    } else {
      throw Exception('Floosak OTP Confirmation failed: ${response.body}');
    }
  }

  Future<bool> logout({required String token}) async {
    final url = Uri.parse('$baseUrl/logout');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['isSuccess'] == true;
    } else {
      throw Exception('Logout failed: ${response.body}');
    }
  }
}
