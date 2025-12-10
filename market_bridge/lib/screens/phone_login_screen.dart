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

  static const farmerGreen = Color(0xFF11823F);
  static const buyerBlue = Color(0xFF2F6FED);
  static const bgGrey = Color(0xFFF2F2F2);

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

  Widget roleCard(String key, String label, String subtitle, IconData icon) {
    final selected = role == key;
    final color = key == 'farmer' ? farmerGreen : buyerBlue;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => role = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10)]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 32,
                  color: selected ? Colors.white : color),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color:
                      selected ? Colors.white70 : Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,

      // ✅ APP BAR MATCHING FIGMA
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Phone Verification',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ LABEL
            const Text('Enter phone number',
                style: TextStyle(
                    fontSize: 14, color: Colors.black54)),

            const SizedBox(height: 8),

            // ✅ PHONE INPUT (FIGMA STYLE)
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: const Text('+91',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ ROLE LABEL
            const Text('I am a:',
                style: TextStyle(
                    fontSize: 14, color: Colors.black54)),

            const SizedBox(height: 12),

            // ✅ ROLE CARDS
            Row(
              children: [
                roleCard('farmer', 'Farmer', 'Sell Produce',
                    Icons.agriculture),
                roleCard('buyer', 'Buyer', 'Buy Produce',
                    Icons.shopping_cart),
              ],
            ),

            const Spacer(),

            // ✅ WEB HINT (UNCHANGED)
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Web requires Firebase reCAPTCHA setup to send real OTPs.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),

            // ✅ SEND OTP BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: sending ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  role == 'farmer' ? farmerGreen : buyerBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send OTP',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600,), ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

