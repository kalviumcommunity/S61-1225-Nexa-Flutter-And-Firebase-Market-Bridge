import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../routes.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String verificationId;
  final String selectedRole;
  final String phoneNumber;

  const OtpVerifyScreen({
    super.key,
    required this.verificationId,
    required this.selectedRole,
    required this.phoneNumber,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final otpController = TextEditingController();
  final _auth = AuthService();
  bool loading = false;

  Future<void> _verify() async {
    final code = otpController.text.trim();
    debugPrint('==========================================');
    debugPrint('🔐 VERIFYING OTP');
    debugPrint('OTP Code: $code');
    debugPrint('Code Length: ${code.length}');
    debugPrint('==========================================');
    if (code.length != 6) {
      debugPrint('❌ Invalid OTP length: ${code.length}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 6-digit OTP')));
      return;
    }

    setState(() => loading = true);
    try {
      debugPrint('🔄 Calling Firebase verifyOTP...');
      final user = await _auth.verifyOTP(widget.verificationId, code);
      if (!mounted) return;
      setState(() => loading = false);

      if (user != null) {
        debugPrint('✅ OTP VERIFIED SUCCESSFULLY');
        debugPrint('User ID: ${user.uid}');
        debugPrint('Phone: ${user.phoneNumber}');

        Navigator.pushReplacementNamed(
          context,
          Routes.routeComplete,
          arguments: {
            'phoneNumber': widget.phoneNumber,
            'role': widget.selectedRole,
          },
        );
      } else {
        debugPrint('❌ OTP verification failed - null user');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP verification failed')));
      }
    } catch (e) {
      debugPrint('💥 EXCEPTION IN VERIFY OTP: $e');
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification error: $e')));
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF11823F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Verify OTP', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: const Color(0xFF5B4FB8), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.smartphone_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5),
                children: [
                  const TextSpan(text: "We've sent a 6-digit OTP to\n"),
                  TextSpan(text: widget.phoneNumber, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter OTP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                const SizedBox(height: 8),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit OTP',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400], letterSpacing: 0),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF11823F), width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  // replaced withOpacity on a const with withAlpha(153) (~60%)
                  disabledBackgroundColor: primaryGreen.withAlpha(153),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
              child: const Text('Change phone number', style: TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
