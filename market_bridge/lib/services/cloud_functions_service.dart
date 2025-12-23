// lib/services/cloud_functions_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class CloudFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Send welcome notification to new user
  Future<Map<String, dynamic>?> sendWelcomeNotification({
    required String userName,
    required String userRole,
  }) async {
    try {
      debugPrint('📞 Calling sendWelcomeNotification');
      debugPrint('User Name: $userName');
      debugPrint('User Role: $userRole');

      final callable = _functions.httpsCallable('sendWelcomeNotification');
      final result = await callable.call({
        'userName': userName,
        'userRole': userRole,
      });

      debugPrint('✅ Welcome notification sent successfully');
      debugPrint('Response: ${result.data}');

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Error calling sendWelcomeNotification: $e');
      return null;
    }
  }

  /// Get market statistics
  Future<Map<String, dynamic>?> getMarketStatistics() async {
    try {
      debugPrint('📞 Calling getMarketStatistics');

      final callable = _functions.httpsCallable('getMarketStatistics');
      final result = await callable.call();

      debugPrint('✅ Market statistics fetched successfully');
      debugPrint('Response: ${result.data}');

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Error calling getMarketStatistics: $e');
      return null;
    }
  }

  /// Generic callable function wrapper
  Future<dynamic> callFunction(
      String functionName, {
        Map<String, dynamic>? parameters,
      }) async {
    try {
      debugPrint('📞 Calling function: $functionName');
      if (parameters != null) {
        debugPrint('Parameters: $parameters');
      }

      final callable = _functions.httpsCallable(functionName);
      final result = await callable.call(parameters);

      debugPrint('✅ Function $functionName completed successfully');
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ FirebaseFunctionsException in $functionName:');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      debugPrint('Details: ${e.details}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error calling $functionName: $e');
      rethrow;
    }
  }

  /// Health check
  Future<bool> checkHealth() async {
    try {
      debugPrint('🏥 Checking functions health');

      final callable = _functions.httpsCallable('healthCheck');
      final result = await callable.call();

      final status = result.data['status'] as String?;
      debugPrint('Health status: $status');

      return status == 'healthy';
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return false;
    }
  }
}