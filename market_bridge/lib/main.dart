// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/otp_verify_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/responsive_home.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Market Bridge',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),

      // Use initialRoute + routes (do NOT set `home` to avoid "/" duplication).
      initialRoute: Routes.routeSplash,
      routes: {
        // Ensure these keys match the values in your `routes.dart`
        Routes.routeSplash: (context) => const SplashScreen(),
        Routes.routePhone: (context) => const PhoneLoginScreen(),
        Routes.routeHome: (context) => const ResponsiveHome(),
      },

      // onGenerateRoute handles routes that require arguments (dynamic routes).
      onGenerateRoute: (settings) {
        if (settings.name == Routes.routeOtp) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => OtpVerifyScreen(
              verificationId: args['verificationId'] as String,
              selectedRole: args['selectedRole'] as String,
              phoneNumber: args['phoneNumber'] as String,
            ),
          );
        }

        if (settings.name == Routes.routeComplete) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CompleteProfileScreen(
              phoneNumber: args['phoneNumber'] as String,
              role: args['role'] as String,
            ),
          );
        }

        // Let Flutter handle unknown routes (returns null => 404-style behavior).
        return null;
      },
    );
  }
}
