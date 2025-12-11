// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOTP(
      String phoneNumber,
      Function(String verificationId) onCodeSent, {
        Function(String)? onError,
        Function(User?)? onAutoVerified,
      }) async {
    if (kIsWeb) {
      final msg = 'Phone auth on web requires reCAPTCHA setup.';
      debugPrint('[AuthService] ⚠️ Web platform detected: $msg');
      onError?.call(msg);
      throw UnsupportedError(msg);
    }

    debugPrint('[AuthService] 🚀 Starting phone verification');
    debugPrint('[AuthService] 📞 Phone Number: $phoneNumber');
    debugPrint('[AuthService] ⏰ Timeout: 60 seconds');
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('[AuthService] ✅ VERIFICATION COMPLETED (Auto)');
          debugPrint('[AuthService] Credential: ${credential.smsCode}');
          try {
            final res = await _auth.signInWithCredential(credential);
            debugPrint('[AuthService] ✅ Sign-in successful');
            debugPrint('[AuthService] User UID: ${res.user?.uid}');
            debugPrint('[AuthService] Phone: ${res.user?.phoneNumber}');
            onAutoVerified?.call(res.user);
          } catch (e) {
            debugPrint('[AuthService] ❌ Sign-in failed: $e');
            onAutoVerified?.call(null);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          final code = e.code;
          final msg = e.message ?? e.toString();
          debugPrint('[AuthService] ❌ VERIFICATION FAILED');
          debugPrint('[AuthService] Error Code: $code');
          debugPrint('[AuthService] Error Message: $msg');
          onError?.call('verificationFailed: $code - $msg');
        },

        codeSent: (String verificationId, int? resendToken) {
          debugPrint('[AuthService] ✅ CODE SENT');
          debugPrint('[AuthService] Verification ID: $verificationId');
          debugPrint('[AuthService] Resend Token: $resendToken');
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {debugPrint('[AuthService] ⏱️ Auto-retrieval timeout');
        debugPrint('[AuthService] Verification ID: $verificationId');
        },
      );
    } catch (e) {
      debugPrint('[AuthService] 💥 EXCEPTION: $e');
      onError?.call('exception: $e');
      rethrow;
    }
  }

  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    debugPrint('[AuthService] 🔐 Verifying OTP');
    debugPrint('[AuthService] Verification ID: $verificationId');
    debugPrint('[AuthService] SMS Code: $smsCode');
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      debugPrint('[AuthService] 🔄 Signing in with credential...');
      final result = await _auth.signInWithCredential(credential);
      debugPrint('[AuthService] ✅ OTP VERIFICATION SUCCESS');
      debugPrint('[AuthService] User UID: ${result.user?.uid}');
      debugPrint('[AuthService] Phone: ${result.user?.phoneNumber}');
      return result.user;
    } catch (e) {
      debugPrint('[AuthService] ❌ OTP VERIFICATION FAILED: $e');
      return null;
    }
  }
}
