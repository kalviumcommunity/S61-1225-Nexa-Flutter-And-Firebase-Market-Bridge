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

class _RoleHomeRouterState extends State<RoleHomeRouter> {
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
    // Check if role was passed as argument (from profile completion)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final passedRole = args?['role'] as String?;

    if (passedRole != null) {
      // Role was passed directly, use it
      if (passedRole.toLowerCase() == 'buyer') {
        return const BuyerHomeScreen();
      } else {
        return const ResponsiveHome();
      }
    }

    // No role passed, fetch from Firestore
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
                    'Loading...',
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
          // Error or no data, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/phone');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;
        if (role.toLowerCase() == 'buyer') {
          return const BuyerHomeScreen();
        } else {
          return const ResponsiveHome();
        }
      },
    );
  }
}