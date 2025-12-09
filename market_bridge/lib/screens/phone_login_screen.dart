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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Verification")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Enter Phone Number"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _auth.sendOTP("+91${phoneController.text.trim()}", (verificationId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerifyScreen(verificationId: verificationId),
                    ),
                  );
                });
              },
              child: const Text("Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
