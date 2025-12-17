// lib/screens/role_home_router.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buyer_home_screen.dart';
import 'responsive_home.dart';

class RoleHomeRouter extends StatefulWidget {
  const RoleHomeRouter({Key? key}) : super(key: key);

  @override
  State<RoleHomeRouter> createState() => _RoleHomeRouterState();
}

class _RoleHomeRouterState extends State<RoleHomeRouter>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Rotation animation for loading icon
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    // Pulsing scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // Start repeating animation
    _loadingController.repeat(reverse: true);
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

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF11823F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 40,
                    color: Color(0xFF11823F),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Animated loading text
            FadeTransition(
              opacity: _loadingController,
              child: const Text(
                'Loading your dashboard...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Progress indicator
            SizedBox(
              width: 200,
              child: AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _loadingController.value,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF11823F),
                    ),
                    minHeight: 4,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if role was passed as argument (from profile completion)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final passedRole = args?['role'] as String?;

    if (passedRole != null) {
      // Role was passed directly, use it with fade transition
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _buildHomeScreen(passedRole),
      );
    }

    // No role passed, fetch from Firestore
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // Error or no data, redirect to login with animation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/phone');
          });
          return _buildLoadingScreen();
        }

        final role = snapshot.data!;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            // Custom transition: fade + scale
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuart,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: _buildHomeScreen(role),
        );
      },
    );
  }

  Widget _buildHomeScreen(String role) {
    if (role.toLowerCase() == 'buyer') {
      return const BuyerHomeScreen(key: ValueKey('buyer_home'));
    } else {
      return const ResponsiveHome(key: ValueKey('farmer_home'));
    }
  }
}