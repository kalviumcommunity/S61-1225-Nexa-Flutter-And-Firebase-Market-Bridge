// lib/routes.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:market_bridge/screens/buyer_dashboard_screen.dart';
import 'package:market_bridge/screens/buyer_marketplace_screen.dart';
import 'package:market_bridge/screens/theme_settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/otp_verify_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/role_home_router.dart';
import 'screens/marketplace_screen.dart';
import 'screens/farmer_dashboard_screen.dart';
import 'screens/post_produce_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/map_screen.dart';

class Routes {
  static const String routeSplash = '/';
  static const String routePhone = '/phone';
  static const String routeOtp = '/otp';
  static const String routeComplete = '/complete';
  static const String routeHome = '/home';
  static const String routeMarketPlace = '/marketplace';
  static const String routeListingDetails = '/listing-details';
  static const String routePostProduce = '/post-produce';
  static const String routeDashboard = '/farmer-dashboard';
  static const String routeBuyerDashboard = '/buyer-dashboard';
  static const String routeScrollable = '/scrollable';
  static const String routeMap = '/map';
  static const String routeThemeSettings = '/theme-settings';

  /// Animation duration for route transitions
  static const Duration transitionDuration = Duration(milliseconds: 400);

  /// Get the appropriate transition curve based on route
  static Curve getTransitionCurve(String routeName) {
    switch (routeName) {
      case routeSplash:
        return Curves.easeInOut;
      case routePhone:
      case routeOtp:
        return Curves.easeOutCubic;
      case routeComplete:
        return Curves.easeInOutCubic;
      case routeHome:
        return Curves.easeOut;
      case routeMarketPlace:
      case routeListingDetails:
      case routeDashboard:
      case routePostProduce:
      case routeThemeSettings:
        return Curves.easeInOut;
      default:
        return Curves.easeInOut;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final curve = getTransitionCurve(settings.name ?? '');

    switch (settings.name) {
      case routeSplash:
        return _buildPageRoute(const SplashScreen(), settings, curve: curve);

      case routePhone:
        return _buildPageRoute(
          const PhoneLoginScreen(),
          settings,
          curve: curve,
        );

      case routeOtp:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _errorRoute('Missing OTP arguments');
        }
        return _buildPageRoute(
          OtpVerifyScreen(
            verificationId: args['verificationId'] as String,
            selectedRole: args['selectedRole'] as String,
            phoneNumber: args['phoneNumber'] as String,
          ),
          settings,
          curve: curve,
        );

      case routeMap:
        return _buildPageRoute(const MapScreen(), settings, curve: curve);

      case routeComplete:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          CompleteProfileScreen(
            phoneNumber: args?['phoneNumber'] as String? ?? '',
            role: args?['role'] as String? ?? '',
          ),
          settings,
          curve: curve,
        );

      case routeHome:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          RoleHomeRouter(key: ValueKey(args?['role'] ?? 'home')),
          settings,
          curve: curve,
        );

      case routeMarketPlace:
      // Use BuyerMarketplaceScreen for buyers, MarketplaceScreen for others
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['role'] == 'buyer') {
          return _buildPageRoute(
            const BuyerMarketplaceScreen(),
            settings,
            curve: curve,
          );
        } else {
          return _buildPageRoute(
            const MarketplaceScreen(),
            settings,
            curve: curve,
          );
        }

      case routeDashboard:
        return _buildPageRoute(
          const FarmerDashboardScreen(),
          settings,
          curve: curve,
        );

      case routeBuyerDashboard:
        return _buildPageRoute(
          const BuyerDashboardScreen(),
          settings,
          curve: curve,
        );

      case routePostProduce:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          PostProduceScreen(
            editListing: args?['editListing'] as Map<String, dynamic>?,
            listingId: args?['listingId'] as String?,
          ),
          settings,
          curve: curve,
        );

      case routeScrollable:
        return _buildPageRoute(
          const ResponsiveLayout(),
          settings,
          curve: curve,
        );

      case routeThemeSettings:
        return _buildPageRoute(
          const ThemeSettingsScreen(),
          settings,
          curve: curve,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  /// Build a page route with smooth transitions
  static PageRoute _buildPageRoute(
      Widget page,
      RouteSettings settings, {
        Curve curve = Curves.easeInOut,
      }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: curve.flipped,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Error route when navigation fails
  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF11823F),
          elevation: 0,
          title: const Text(
            'Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11823F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}