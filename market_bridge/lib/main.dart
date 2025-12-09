import 'package:flutter/material.dart';

// Import screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MarketBridgeApp());
}

class MarketBridgeApp extends StatelessWidget {
  const MarketBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketBridge',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
