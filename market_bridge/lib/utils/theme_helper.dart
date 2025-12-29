// lib/utils/theme_helper.dart
import 'package:flutter/material.dart';

class ThemeHelper {
  // Get theme color based on user role
  static Color getThemeColor(String? role) {
    if (role == null) return const Color(0xFF11823F);
    return role.toLowerCase() == 'buyer'
        ? const Color(0xFF2196F3) // Blue for buyers
        : const Color(0xFF11823F); // Green for farmers
  }

  // Get light theme color based on user role
  static Color getLightThemeColor(String? role) {
    if (role == null) return const Color(0xFFE8F5E9);
    return role.toLowerCase() == 'buyer'
        ? const Color(0xFFE3F2FD) // Light blue for buyers
        : const Color(0xFFE8F5E9); // Light green for farmers
  }

  // Get icon based on user role
  static IconData getRoleIcon(String? role) {
    if (role == null) return Icons.person;
    return role.toLowerCase() == 'buyer'
        ? Icons.shopping_bag_rounded
        : Icons.agriculture_rounded;
  }

  // Get role-based text color for status badges
  static Color getStatusColor(String? role, String status) {
    final baseColor = getThemeColor(role);

    switch (status.toLowerCase()) {
      case 'active':
      case 'confirmed':
        return Colors.green[700]!;
      case 'pending':
        return Colors.orange[700]!;
      case 'delivered':
        return Colors.blue[700]!;
      case 'cancelled':
        return Colors.red[700]!;
      default:
        return baseColor;
    }
  }

  // Get role-based background color for status badges
  static Color getStatusBgColor(String? role, String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'confirmed':
        return Colors.green.withOpacity(0.1);
      case 'pending':
        return Colors.orange.withOpacity(0.1);
      case 'delivered':
        return Colors.blue.withOpacity(0.1);
      case 'cancelled':
        return Colors.red.withOpacity(0.1);
      default:
        return getLightThemeColor(role);
    }
  }
}