// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends an OTP. onCodeSent called when verificationId is available.
  /// onError called with an error string on failure.
  Future<void> sendOTP(
      String phoneNumber,
      Function(String verificationId) onCodeSent, {
        Function(String)? onError,
      }) async {
    if (kIsWeb) {
      final msg = 'Phone auth on web requires reCAPTCHA setup.';
      print('[AuthService] web unsupported: $msg');
      onError?.call(msg);
      throw UnsupportedError(msg);
    }

    print('[AuthService] verifyPhoneNumber start -> $phoneNumber');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This is called on Android when auto-retrieval works.
          print('[AuthService] verificationCompleted: credential=$credential');
          try {
            final res = await _auth.signInWithCredential(credential);
            print('[AuthService] signInWithCredential succeeded: uid=${res.user?.uid}');
          } catch (e) {
            print('[AuthService] signInWithCredential FAILED: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          final code = e.code;
          final msg = e.message ?? e.toString();
          print('[AuthService] verificationFailed -> code: $code message: $msg');
          onError?.call('verificationFailed: $code - $msg');
        },
        codeSent: (String verificationId, int? resendToken) async {
          print('[AuthService] codeSent -> verificationId: $verificationId resendToken: $resendToken');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('[AuthService] codeAutoRetrievalTimeout -> verificationId: $verificationId');
        },
      );
    } catch (e) {
      print('[AuthService] verifyPhoneNumber threw: $e');
      onError?.call('exception: $e');
      rethrow;
    }
  }

  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      final result = await _auth.signInWithCredential(credential);
      print('[AuthService] verifyOTP success: uid=${result.user?.uid}');
      return result.user;
    } catch (e) {
      print('[AuthService] verifyOTP failed: $e');
      return null;
    }
  }
}
