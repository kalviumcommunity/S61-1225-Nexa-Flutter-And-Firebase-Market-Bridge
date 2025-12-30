// lib/main.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_bridge/local_notification_service.dart';
import 'package:market_bridge/screens/map_screen.dart';
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
import 'widgets/loading_widget.dart';
import 'widgets/error_widget.dart';
import 'utils/theme_helper.dart';
/// Background handler (top-level)
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Android 13+
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await LocalNotificationService.initialize();

  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");

  // Background handler (NO UI work here)
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // Foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      LocalNotificationService.show(
        notification.title ?? 'MarketBridge',
        notification.body ?? '',
      );
    }
  });

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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      onGenerateRoute: (settings) {
        final curve = Routes.getTransitionCurve(settings.name ?? '');
        switch (settings.name) {
          case Routes.routeSplash:
            return _buildFadeRoute(const SplashScreen(), settings);
          case Routes.routePhone:
            return _buildSlideRoute(
              const PhoneLoginScreen(),
              settings,
              curve: curve,
            );
          case Routes.routeOtp:
            final args = settings.arguments as Map<String, dynamic>;
            return _buildSlideRoute(
              OtpVerifyScreen(
                verificationId: args['verificationId'],
                selectedRole: args['selectedRole'],
                phoneNumber: args['phoneNumber'],
              ),
              settings,
              curve: curve,
            );
          case Routes.routeComplete:
            final args = settings.arguments as Map<String, dynamic>;
            return _buildScaleFadeRoute(
              CompleteProfileScreen(
                phoneNumber: args['phoneNumber'],
                role: args['role'],
              ),
              settings,
              curve: curve,
            );
          case Routes.routeHome:
            return _buildFadeRoute(
              const RoleHomeRouter(),
              settings,
              curve: curve,
            );
          case Routes.routeMarketPlace:
            return _buildSlideRoute(
              const MarketplaceScreen(),
              settings,
              curve: curve,
            );
          case Routes.routeDashboard:
            return _buildSlideUpRoute(
              const DashboardRouter(),
              settings,
              curve: curve,
            );
          case Routes.routePostProduce:
            return _buildSlideUpRoute(
              const PostProduceScreen(),
              settings,
              curve: curve,
            );
          case Routes.routeListingDetails:
            final args = settings.arguments as Map<String, dynamic>?;
            return _buildScaleFadeRoute(
              ListingDetailsScreen(crop: args?['crop'] ?? {}),
              settings,
              curve: curve,
            );
          case Routes.routeMap:
            return _buildFadeRoute(
              const MapScreen(),
              settings,
              curve: curve,
            );
          case '/scrollable':
            return _buildSlideRoute(
              const ResponsiveLayout(),
              settings,
              curve: curve,
            );
          default:
            return _buildFadeRoute(const SplashScreen(), settings);
        }
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const RoleHomeRouter();
          }
          return const PhoneLoginScreen();
        },
      ),
    );
  }

  /// Slide transition from right
  PageRouteBuilder _buildSlideRoute(
      Widget page,
      RouteSettings settings, {
        Curve curve = Curves.easeInOutCubic,
      }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Routes.transitionDuration,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;

        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Fade transition
  PageRouteBuilder _buildFadeRoute(
      Widget page,
      RouteSettings settings, {
        Curve curve = Curves.easeIn,
      }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  /// Scale and fade transition
  PageRouteBuilder _buildScaleFadeRoute(
      Widget page,
      RouteSettings settings, {
        Curve curve = Curves.easeOutQuart,
      }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var scaleTween = Tween<double>(begin: 0.85, end: 1.0)
            .chain(CurveTween(curve: curve));
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide up transition (for modals)
  PageRouteBuilder _buildSlideUpRoute(
      Widget page,
      RouteSettings settings, {
        Curve curve = Curves.easeOutCubic,
      }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.3);
        const end = Offset.zero;

        var slideTween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
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

class _DashboardRouterState extends State<DashboardRouter>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

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
                children: [
                  RotationTransition(
                    turns: _loadingController,
                    child: const Icon(
                      Icons.agriculture,
                      size: 48,
                      color: Color(0xFF11823F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading Dashboard...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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