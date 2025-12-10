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
  String role = 'farmer';
  bool sending = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  // Build final E.164 phone number (Indian default)
  String _buildPhoneNumber(String raw) {
    raw = raw.trim();
    if (raw.isEmpty) return '';

    // If user types a full E.164 number starting with +
    if (raw.startsWith('+')) {
      // sanitize spaces etc.
      return raw.replaceAll(' ', '');
    }

    // Remove non-digits and assume Indian local number
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    // If user accidentally typed country code without + e.g., 919876543210
    if (digits.length >= 11 && digits.startsWith('91')) {
      return '+$digits';
    }
    // Otherwise assume it's a 10-digit Indian mobile and prepend +91
    return '+91$digits';
  }

  Future<void> _sendOtp() async {
    final raw = phoneController.text;
    if (raw.trim().isEmpty) {
      _showSnackbar('Please enter your phone number.');
      return;
    }

    final phoneNumber = _buildPhoneNumber(raw);
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Basic validation: ensure at least 8-ish digits (simple)
    if (digitsOnly.length < 8) {
      _showSnackbar('Enter a valid phone number.');
      return;
    }

    print('📞 Attempting sendOTP -> $phoneNumber');
    setState(() => sending = true);

    try {
      await _auth.sendOTP(phoneNumber, (verificationId) {
        print('✔ codeSent verificationId=$verificationId');
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
        print('❌ sendOTP error: $err');
        _showSnackbar('Failed to send OTP: $err');
      });
    } catch (e) {
      print('❌ sendOTP thrown: $e');
      _showSnackbar('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void _showSnackbar(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  Widget roleCard(String key, String label, IconData icon) {
    final selected = role == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => role = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF11823F) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: selected ? [BoxShadow(color: Colors.green.withOpacity(0.12), blurRadius: 6)] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: selected ? Colors.white : Colors.black54),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
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
      appBar: AppBar(title: const Text('Phone Verification'), backgroundColor: const Color(0xFF11823F)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            // Phone input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
              child: Row(
                children: [
                  // show +91 visually if user didn't type +
                  if (!phoneController.text.startsWith('+')) const Text('+91', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Enter mobile (e.g., 9876543210 or +919876543210)',
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(children: [
              roleCard('farmer', 'Farmer\n(Sell Produce)', Icons.agriculture),
              roleCard('buyer', 'Buyer\n(Buy Produce)', Icons.shopping_bag),
            ]),

            const Spacer(),

            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Web requires Firebase reCAPTCHA setup to send real OTPs.', style: TextStyle(color: Colors.grey.shade600)),
              ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: sending ? null : _sendOtp,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11823F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: sending ? const CircularProgressIndicator(color: Colors.white) : const Text('Send OTP', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
