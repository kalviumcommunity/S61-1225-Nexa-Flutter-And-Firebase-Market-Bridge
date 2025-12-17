// lib/routes.dart
import 'package:flutter/material.dart';

class Routes {
  static const routeSplash = '/';
  static const routePhone = '/phone';
  static const routeOtp = '/otp';
  static const routeComplete = '/complete';
  static const routeHome = '/home';
  static const routeMarketPlace = '/marketplace';
  static const routeListingDetails = '/listing-details';
  static const String routePostProduce = '/post-produce';
  static const String routeDashboard = '/farmer-dashboard';

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
        return Curves.easeInOut;
      default:
        return Curves.easeInOut;
    }
  }
}
