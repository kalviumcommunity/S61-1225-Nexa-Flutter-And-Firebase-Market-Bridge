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
  late final AnimationController _loadingController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.linear,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );
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

      return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('Role fetch error: $e');
      return null;
    }
  }

  /// =======================
  /// LOADING SCREEN (Responsive)
  /// =======================
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isTablet = screenWidth >= 600;

          final iconSize =
              isTablet ? constraints.maxWidth * 0.12 : constraints.maxWidth * 0.2;
          final iconInnerSize = iconSize * 0.5;

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFF11823F).withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(isTablet ? 20 : 16),
                        ),
                        child: Icon(
                          Icons.agriculture,
                          size: iconInnerSize,
                          color: const Color(0xFF11823F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _loadingController,
                    child: Text(
                      'Loading your dashboard...',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: isTablet
                        ? constraints.maxWidth * 0.4
                        : constraints.maxWidth * 0.6,
                    child: LinearProgressIndicator(
                      value: _loadingController.value,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF11823F)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final passedRole = args?['role'] as String?;

    if (passedRole != null) {
      return AnimatedSwitcher(
        duration: Duration(milliseconds: isTablet ? 600 : 500),
        child: _buildHomeScreen(passedRole),
      );
    }

    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/phone');
          });
          return _buildLoadingScreen();
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: isTablet ? 700 : 600),
          child: _buildHomeScreen(snapshot.data!),
        );
      },
    );
  }

  Widget _buildHomeScreen(String role) {
    return role.toLowerCase() == 'buyer'
        ? const BuyerHomeScreen(key: ValueKey('buyer_home'))
        : const ResponsiveHomeEnhanced(key: ValueKey('farmer_home'));
  }
}
