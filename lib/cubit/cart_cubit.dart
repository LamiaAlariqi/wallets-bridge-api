import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/product.dart';
import '../services/wallet_api_service.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState([], 0.0));

  void addToCart(Product product) {
    final updatedCart = List<Product>.from(state.cartItems)..add(product);
    final updatedTotal = state.totalPrice + product.price;
    emit(CartState(updatedCart, updatedTotal));
  }

  Future<bool> processJaibPurchase({
    required String token,
    String? code,
  }) async {
    emit(CartPurchasing(state.cartItems, state.totalPrice));
    
    try {
      final itemsMap = state.cartItems.map((p) => {
        'id': p.id,
        'name': p.title,
        'quantity': 1,
        'price': p.price,
      }).toList();

      final success = await WalletApiService().jaibPurchase(
        token: token,
        amount: state.totalPrice,
        code: code,
        items: itemsMap,
      );

      if (success) {
        emit(const CartState([], 0.0));
        return true;
      } else {
        emit(CartState(state.cartItems, state.totalPrice)); // Revert visual loading
        return false;
      }
    } catch (e) {
      emit(CartState(state.cartItems, state.totalPrice));
      return false;
    }
  }

  Future<String?> initiateFloosakPurchase({
    required String token,
  }) async {
    emit(CartPurchasing(state.cartItems, state.totalPrice));
    
    try {
      final itemsMap = state.cartItems.map((p) => {
        'id': p.id,
        'name': p.title,
        'quantity': 1,
        'price': p.price,
      }).toList();

      final referenceId = await WalletApiService().floosakInitiatePurchase(
        token: token,
        amount: state.totalPrice,
        items: itemsMap,
      );

      emit(CartState(state.cartItems, state.totalPrice)); 
      return referenceId;
    } catch (e) {
      emit(CartState(state.cartItems, state.totalPrice));
      return null;
    }
  }

  Future<bool> confirmFloosakPurchase({
    required String token,
    required String referenceId,
    required String otp,
  }) async {
    emit(CartPurchasing(state.cartItems, state.totalPrice));
    
    try {
      final itemsMap = state.cartItems.map((p) => {
        'id': p.id,
        'name': p.title,
        'quantity': 1,
        'price': p.price,
      }).toList();

      final success = await WalletApiService().floosakConfirmOtp(
        token: token,
        referenceId: referenceId,
        otp: otp,
        items: itemsMap,
      );

      if (success) {
        emit(const CartState([], 0.0));
        return true;
      } else {
        emit(CartState(state.cartItems, state.totalPrice));
        return false;
      }
    } catch (e) {
      emit(CartState(state.cartItems, state.totalPrice));
      return false;
    }
  }
}
