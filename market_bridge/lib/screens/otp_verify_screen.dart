import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'complete_profile_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String verificationId;
  const OtpVerifyScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final otpController = TextEditingController();
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: "Enter OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = await _auth.verifyOTP(widget.verificationId, otpController.text.trim());
                if (user != null) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()));
                }
              },
              child: const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
