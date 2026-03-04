part of 'cart_cubit.dart';

class CartState extends Equatable {
  final List<Product> cartItems;
  final double totalPrice;

  const CartState(this.cartItems, this.totalPrice);

  @override
  List<Object> get props => [cartItems, totalPrice];
}

class CartPurchasing extends CartState {
  const CartPurchasing(super.cartItems, super.totalPrice);
}
