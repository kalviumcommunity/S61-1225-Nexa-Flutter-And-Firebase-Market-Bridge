// lib/screens/role_home_router.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/theme_helper.dart';
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
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
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
      if (user == null) {
        debugPrint('❌ No authenticated user found');
        return null;
      }

      debugPrint('✅ Fetching role for user: ${user.uid}');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        debugPrint('⚠️ User document does not exist');
        return null;
      }

      final role = doc.data()?['role'] as String?;
      debugPrint('✅ User role: $role');
      return role;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching user role: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Widget _buildLoadingScreen({String? role}) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isTablet = screenWidth >= 600;

          final iconSize = isTablet
              ? constraints.maxWidth * 0.12
              : constraints.maxWidth * 0.2;
          final iconInnerSize = iconSize * 0.5;

          // Determine icon and color based on role
          final isBuyer = (role?.toLowerCase() == 'buyer');
          final iconData = isBuyer ? Icons.shopping_cart : Icons.agriculture;
          final iconColor = isBuyer ? Color(0xFF1976D2) : Color(0xFF11823F);
          final bgColor = iconColor.withOpacity(0.1);
          final loadingText = isBuyer
              ? 'Loading your buyer dashboard...'
              : 'Loading your dashboard...';

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
                          color: bgColor,
                          borderRadius: BorderRadius.circular(
                            isTablet ? 20 : 16,
                          ),
                        ),
                        child: Icon(
                          iconData,
                          size: iconInnerSize,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _loadingController,
                    child: Text(
                      loadingText,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: isTablet
                        ? constraints.maxWidth * 0.4
                        : constraints.maxWidth * 0.6,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(iconColor),
                      minHeight: 4,
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

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isTablet = screenWidth >= 600;

          return Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 48 : 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: isTablet ? 100 : 80,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: isTablet ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 40 : 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.routePhone,
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11823F),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
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
          // If we have a role from arguments, use it, else null
          return _buildLoadingScreen(role: passedRole);
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(
            'Unable to load your profile. Please check your internet connection and try again.',
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, Routes.routePhone);
          });
          return _buildLoadingScreen(role: passedRole);
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: isTablet ? 700 : 600),
          child: _buildHomeScreen(snapshot.data!),
        );
      },
    );
  }

  Widget _buildHomeScreen(String role) {
    if (role.toLowerCase() == 'buyer') {
      return BuyerHomeScreen();
    } else {
      return FarmerHomeScreenEnhanced();
    }
  }
}