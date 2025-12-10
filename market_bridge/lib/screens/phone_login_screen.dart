// lib/screens/phone_login_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_verify_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final phoneController = TextEditingController();
  final _auth = AuthService();
  String role = 'farmer'; // farmer or buyer
  bool sending = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final raw = phoneController.text.trim();
    if (raw.isEmpty) {
      _showSnackbar('Please enter your phone number.');
      return;
    }
    // basic validation: digits only and length >= 6 (adjust if you want)
    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 6) {
      _showSnackbar('Enter a valid phone number.');
      return;
    }

    final phoneNumber = '+91$digitsOnly'; // keep +91 if your app targets India
    setState(() => sending = true);

    try {
      // on web, AuthService will throw an UnsupportedError unless you've set up reCAPTCHA;
      // we still call it and surface any error message via the callback.
      await _auth.sendOTP(phoneNumber, (verificationId) {
        // OTP code was sent — navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerifyScreen(
              verificationId: verificationId,
              selectedRole: role,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      }, onError: (err) {
        // show error to user
        _showSnackbar('Failed to send OTP: $err');
      });

      // Note: sendOTP may call codeSent synchronously or after some time.
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget roleCard(String key, String label, IconData icon) {
    final selected = role == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => role = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF11823F) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: selected
                ? [BoxShadow(color: Colors.green.withOpacity(0.12), blurRadius: 8)]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: selected ? Colors.white : Colors.black54),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Phone Verification'),
        backgroundColor: const Color(0xFF11823F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            // phone card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  const Text('+91', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Enter phone number',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // role selector
            Row(
              children: [
                roleCard('farmer', 'Farmer\n(Sell Produce)', Icons.agriculture),
                roleCard('buyer', 'Buyer\n(Buy Produce)', Icons.shopping_bag),
              ],
            ),

            const Spacer(),

            // dev note when running on web
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Web platform detected — make sure you configured Firebase reCAPTCHA in Firebase console.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

            // send OTP button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: sending ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11823F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: sending
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                    : const Text('Send OTP', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
