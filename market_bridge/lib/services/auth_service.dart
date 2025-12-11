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
      debugPrint('[AuthService] web unsupported: $msg');
      onError?.call(msg);
      throw UnsupportedError(msg);
    }

    debugPrint('[AuthService] verifyPhoneNumber start -> $phoneNumber');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('[AuthService] verificationCompleted: credential=$credential');
          try {
            final res = await _auth.signInWithCredential(credential);
            debugPrint('[AuthService] signInWithCredential succeeded: uid=${res.user?.uid}');
            onAutoVerified?.call(res.user);
          } catch (e) {
            debugPrint('[AuthService] signInWithCredential FAILED: $e');
            onAutoVerified?.call(null);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          final code = e.code;
          final msg = e.message ?? e.toString();
          debugPrint('[AuthService] verificationFailed -> code: $code message: $msg');
          onError?.call('verificationFailed: $code - $msg');
        },

        codeSent: (String verificationId, int? resendToken) {
          debugPrint('[AuthService] codeSent -> verificationId: $verificationId resendToken: $resendToken');
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('[AuthService] codeAutoRetrievalTimeout -> verificationId: $verificationId');
        },
      );
    } catch (e) {
      debugPrint('[AuthService] verifyPhoneNumber threw: $e');
      onError?.call('exception: $e');
      rethrow;
    }
  }

  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _auth.signInWithCredential(credential);
      debugPrint('[AuthService] verifyOTP success: uid=${result.user?.uid}');
      return result.user;
    } catch (e) {
      debugPrint('[AuthService] verifyOTP failed: $e');
      return null;
    }
  }
}
