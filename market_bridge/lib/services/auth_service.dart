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
      const msg = 'Phone auth on web requires reCAPTCHA setup.';
      onError?.call(msg);
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        /// 🔴 FIX: DO NOT auto sign-in blindly
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('[AuthService] ⚠️ Auto verification callback received');

          // ❌ Skip auto login for safety
          // Let user verify OTP manually
          // This avoids Firebase blocking
        },

        verificationFailed: (FirebaseAuthException e) {
          debugPrint('[AuthService] ❌ VERIFICATION FAILED');
          debugPrint('[AuthService] Code: ${e.code}');
          debugPrint('[AuthService] Message: ${e.message}');
          onError?.call(e.message ?? e.code);
        },

        codeSent: (String verificationId, int? resendToken) {
          debugPrint('[AuthService] ✅ CODE SENT');
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('[AuthService] ⏱️ Auto-retrieval timeout');
        },
      );
    } catch (e) {
      debugPrint('[AuthService] 💥 EXCEPTION: $e');
      onError?.call(e.toString());
    }
  }

  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] ❌ OTP FAILED');
      debugPrint('[AuthService] Code: ${e.code}');
      debugPrint('[AuthService] Message: ${e.message}');
      rethrow;
    }
  }
}
