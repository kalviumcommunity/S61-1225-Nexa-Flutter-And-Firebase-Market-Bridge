import 'package:flutter/material.dart';
import 'phone_login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match Figma: full green screen, centered basket icon and MarketBridge text
      backgroundColor: const Color(0xFF11823F),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // small basket emoji icon to mimic Figma illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🧺', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'MarketBridge',
                style: TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Transparent prices • Direct buyers • Alerts',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhoneLoginScreen(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(color: Color(0xFF11823F)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
