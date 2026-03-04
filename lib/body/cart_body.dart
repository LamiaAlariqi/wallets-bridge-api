import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/cart_cubit.dart';

class CartBody extends StatefulWidget {
  const CartBody({super.key});

  @override
  State<CartBody> createState() => _CartBodyState();
}

class _CartBodyState extends State<CartBody> {
  String _selectedWallet = 'jaib';

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String walletName, CartState cartState) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.payment, color: Colors.blue),
              SizedBox(width: 10),
              Text('Confirm Payment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please explicitly verify your payment details before proceeding:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(13),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Wallet Selected', walletName),
                    const Divider(),
                    _buildDetailRow('Number of Items', '${cartState.cartItems.length} Items'),
                    const Divider(),
                    _buildDetailRow(
                      'Total Amount',
                      '${cartState.totalPrice.toStringAsFixed(2)}\$',
                      isBold: true,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm & Pay'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showJaibCodeDialog(BuildContext context) {
    final jaibCodeController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter Jaib Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your Jaib Payment Code (Default: 1112)'),
              const SizedBox(height: 10),
              TextField(
                controller: jaibCodeController,
                decoration: const InputDecoration(
                  labelText: 'Jaib Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredCode = jaibCodeController.text.trim();
                if (enteredCode.isNotEmpty) {
                  Navigator.pop(dialogContext, enteredCode);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showFloosakOtpDialog(BuildContext context) {
    final otpController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the OTP sent to your phone (Default: 123456)'),
              const SizedBox(height: 10),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredOtp = otpController.text.trim();
                if (enteredOtp.isNotEmpty) {
                  Navigator.pop(dialogContext, enteredOtp);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _processCheckout(BuildContext context) async {
    final cartState = context.read<CartCubit>().state;
    if (cartState.cartItems.isEmpty) return;

    final String walletName = _selectedWallet == 'jaib' ? 'Jaib' : 'Floosak';

    bool? confirm = await _showConfirmDialog(context, walletName, cartState);
    if (confirm != true || !context.mounted) return;

    final authState = context.read<AuthCubit>().state;
    String? token;
    
    if (authState is Authenticated) {
      token = authState.token;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    if (_selectedWallet == 'jaib') {
      final String? jaibCode = await _showJaibCodeDialog(context);
      if (jaibCode == null || !context.mounted) return;

      final success = await context.read<CartCubit>().processJaibPurchase(
        token: token,
        code: jaibCode,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Successful via Jaib!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_selectedWallet == 'floosak') {
      final referenceId = await context
          .read<CartCubit>()
          .initiateFloosakPurchase(token: token);

      if (referenceId != null && context.mounted) {
        final String? otp = await _showFloosakOtpDialog(context);

        if (otp != null && context.mounted) {
          final success = await context
              .read<CartCubit>()
              .confirmFloosakPurchase(
                token: token,
                referenceId: referenceId,
                otp: otp,
              );

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment Successful via Floosak!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP Confirmation Failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Cancelled.')));
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initiate Floosak purchase.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocConsumer<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartPurchasing) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Processing E-Wallet Purchase Request...'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.cartItems.isEmpty && state is! CartPurchasing) {
              return const Center(child: Text('Your cart is empty'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return ListTile(
                        leading: Image.network(
                          item.image,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                        title: Text(item.title, maxLines: 1),
                        trailing: Text(
                          '${item.price.toStringAsFixed(2)}\$',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  color: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Payment Method:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'jaib',
                            groupValue: _selectedWallet,
                            onChanged: (value) {
                              setState(() {
                                _selectedWallet = value!;
                              });
                            },
                          ),
                          const Text('Jaib'),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'floosak',
                            groupValue: _selectedWallet,
                            onChanged: (value) {
                              setState(() {
                                _selectedWallet = value!;
                              });
                            },
                          ),
                          const Text('Floosak'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(128),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${state.totalPrice.toStringAsFixed(2)}\$',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: state is CartPurchasing
                              ? null
                              : () => _processCheckout(context),
                          child: state is CartPurchasing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Buy'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
