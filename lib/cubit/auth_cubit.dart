import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/wallet_api_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final WalletApiService apiService;

  AuthCubit(this.apiService) : super(AuthInitial()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      emit(Authenticated(token));
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final token = await apiService.register(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
      );

      if (token != null) {
        await _saveToken(token);
        emit(Authenticated(token));
      } else {
        emit(const AuthError('Failed to retrieve token from the server.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final token = await apiService.login(email: email, password: password);

      if (token != null) {
        await _saveToken(token);
        emit(Authenticated(token));
      } else {
        emit(const AuthError('Failed to retrieve token from the server.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      emit(AuthLoading());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        await apiService.logout(token: token);
      }
      await prefs.remove('auth_token');
      emit(AuthInitial());
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      emit(AuthInitial());
    }
  }
}
