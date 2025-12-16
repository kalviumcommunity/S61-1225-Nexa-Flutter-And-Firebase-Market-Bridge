// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/splash_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/otp_verify_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/role_home_router.dart';
import 'screens/marketplace_screen.dart';
import 'screens/farmer_dashboard_screen.dart';
import 'screens/buyer_dashboard_screen.dart';
import 'screens/post_produce_screen.dart';
import 'screens/responsive_layout.dart';
import 'routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: Routes.routeSplash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.routeSplash:
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );

          case Routes.routePhone:
            return MaterialPageRoute(
              builder: (_) => const PhoneLoginScreen(),
            );

          case Routes.routeOtp:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => OtpVerifyScreen(
                verificationId: args['verificationId'],
                selectedRole: args['selectedRole'],
                phoneNumber: args['phoneNumber'],
              ),
            );

          case Routes.routeComplete:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CompleteProfileScreen(
                phoneNumber: args['phoneNumber'],
                role: args['role'],
              ),
            );

          case Routes.routeHome:
          // This will route to appropriate home based on role
            return MaterialPageRoute(
              builder: (_) => const RoleHomeRouter(),
              settings: settings, // Pass settings to access arguments
            );

          case Routes.routeMarketPlace:
            return MaterialPageRoute(
              builder: (_) => const MarketplaceScreen(),
            );

          case Routes.routeDashboard:
          // Route to appropriate dashboard based on user role
            return MaterialPageRoute(
              builder: (_) => const DashboardRouter(),
            );

          case Routes.routePostProduce:
            return MaterialPageRoute(
              builder: (_) => const PostProduceScreen(),
            );

          case Routes.routeListingDetails:
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ListingDetailsScreen(crop: args?['crop'] ?? {}),
            );

          case '/scrollable':
            return MaterialPageRoute(
              builder: (_) => const ResponsiveLayout(),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
        }
      },
    );
  }
}

// Dashboard router to show appropriate dashboard based on role
class DashboardRouter extends StatefulWidget {
  const DashboardRouter({Key? key}) : super(key: key);

  @override
  State<DashboardRouter> createState() => _DashboardRouterState();
}

class _DashboardRouterState extends State<DashboardRouter> {
  Future<String?> _getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading Dashboard...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // Error or no data, go back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;
        if (role.toLowerCase() == 'buyer') {
          return const BuyerDashboardScreen();
        } else {
          return const FarmerDashboardScreen();
        }
      },
    );
  }
}