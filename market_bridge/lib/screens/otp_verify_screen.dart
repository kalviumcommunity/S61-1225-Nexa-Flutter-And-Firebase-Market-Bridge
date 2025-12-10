import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'complete_profile_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String verificationId;
  final String selectedRole;
  final String phoneNumber;

  const OtpVerifyScreen({
    Key? key,
    required this.verificationId,
    required this.selectedRole,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final otpController = TextEditingController();
  final _auth = AuthService();
  bool loading = false;

  Future<void> _verify() async {
    final code = otpController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid OTP')));
      return;
    }
    setState(() => loading = true);
    final user = await _auth.verifyOTP(widget.verificationId, code);
    setState(() => loading = false);

    if (user != null) {
      // pass role and phone to complete profile screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(
            phoneNumber: widget.phoneNumber,
            role: widget.selectedRole,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('OTP verification failed')));
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: const Color(0xFF11823F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Icon(Icons.phone_android, size: 44, color: Colors.black54),
                  const SizedBox(height: 8),
                  Text("We've sent a 6-digit OTP to ${widget.phoneNumber}",
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11823F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Verify OTP"),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () {
                  // allow changing phone: go back
                  Navigator.pop(context);
                },
                child: const Text('Change phone number')),
          ],
        ),
      ),
    );
  }
}
