import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/cart_cubit.dart';
import 'cubit/product_cubit.dart';
import 'cubit/auth_cubit.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/api_service.dart';
import 'services/wallet_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductCubit(ApiService())),
        BlocProvider(create: (context) => CartCubit()),
        BlocProvider(create: (context) => AuthCubit(WalletApiService())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Store',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const HomeScreen();
            }
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}
