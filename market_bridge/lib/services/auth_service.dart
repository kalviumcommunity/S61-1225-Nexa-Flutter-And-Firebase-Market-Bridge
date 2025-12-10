// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// onCodeSent will be called when verificationId is available.
  /// onError will be called on failure with a message.
  Future<void> sendOTP(String phoneNumber, Function(String verificationId) onCodeSent,
      {Function(String)? onError}) async {
    // On web, Firebase requires a reCAPTCHA verifier and uses signInWithPhoneNumber.
    if (kIsWeb) {
      onError?.call('Phone auth on web requires reCAPTCHA setup. See Firebase docs.');
      throw UnsupportedError('Phone auth on web needs reCAPTCHA.');
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android: auto sign-in with SMS auto-retrieval.
          try {
            await _auth.signInWithCredential(credential);
          } catch (_) {
            // ignore auto sign-in failures
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          final msg = e.message ?? e.code;
          onError?.call(msg);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // optional: you can notify UI that auto retrieval timed out
        },
      );
    } catch (e) {
      onError?.call(e.toString());
      rethrow;
    }
  }

  Future<User?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print('verifyOTP failed: $e');
      return null;
    }
  }
}
