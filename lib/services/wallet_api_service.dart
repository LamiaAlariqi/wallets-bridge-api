import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class WalletApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;

  WalletApiResponse({required this.isSuccess, required this.message, this.data});
}

class WalletApiService {
  static const String baseUrl = 'https://wallets-workshop.dev-options.com/api';

  String _extractMessage(http.Response response, [String defaultMessage = 'An error occurred']) {
    try {
      final data = json.decode(response.body);
      return data['message'] ?? defaultMessage;
    } catch (_) {
      return defaultMessage;
    }
  }

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
      throw ApiException(_extractMessage(response, 'Failed to register'));
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
      throw ApiException(_extractMessage(response, 'Failed to login'));
    }
  }

  Future<WalletApiResponse<void>> jaibPurchase({
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
      return WalletApiResponse<void>(
        isSuccess: data['isSuccess'] == true,
        message: data['message'] ?? 'Payment processed successfully',
      );
    } else {
      throw ApiException(_extractMessage(response, 'Jaib Purchase failed'));
    }
  }

  Future<WalletApiResponse<String>> floosakInitiatePurchase({
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
      bool isSuccess = data['isSuccess'] == true;
      return WalletApiResponse<String>(
        isSuccess: isSuccess,
        message: data['message'] ?? (isSuccess ? 'Purchase initiated' : 'Failed to initiate purchase'),
        data: data['data']?['wallet_reference_id']?.toString(),
      );
    } else {
      throw ApiException(_extractMessage(response, 'Floosak Purchase failed'));
    }
  }

  Future<WalletApiResponse<void>> floosakConfirmOtp({
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
      return WalletApiResponse<void>(
        isSuccess: data['isSuccess'] == true,
        message: data['message'] ?? 'Payment confirmed successfully',
      );
    } else {
      throw ApiException(_extractMessage(response, 'Floosak OTP Confirmation failed'));
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
      throw ApiException(_extractMessage(response, 'Logout failed'));
    }
  }
}
