// lib/screens/phone_login_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'otp_verify_screen.dart';
import '../routes.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with SingleTickerProviderStateMixin {
  final phoneController = TextEditingController();
  final _auth = AuthService();
  String role = 'farmer';
  bool sending = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const farmerGreen = Color(0xFF11823F);
  static const buyerBlue = Color(0xFF2F6FED);
  static const bgGrey = Color(0xFFF2F2F2);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _buildPhoneNumber(String raw) {
    raw = raw.trim();
    if (raw.isEmpty) return '';

    if (raw.startsWith('+')) {
      return raw.replaceAll(' ', '');
    }

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 11 && digits.startsWith('91')) {
      return '+$digits';
    }
    return '+91$digits';
  }

  Future<void> _sendOtp() async {
    final raw = phoneController.text;
    if (raw.trim().isEmpty) {
      _showSnackbar('Please enter your phone number.');
      return;
    }

    final phoneNumber = _buildPhoneNumber(raw);
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 8) {
      _showSnackbar('Enter a valid phone number.');
      return;
    }

    debugPrint('==========================================');
    debugPrint('📞 SENDING OTP');
    debugPrint('Phone Number: $phoneNumber');
    debugPrint('User Role: $role');
    debugPrint('Timestamp: ${DateTime.now()}');
    debugPrint('==========================================');

    setState(() => sending = true);

    try {
      await _auth.sendOTP(
        phoneNumber,
            (verificationId) {
          debugPrint('✅ OTP SENT SUCCESSFULLY');
          debugPrint('Verification ID: $verificationId');
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            Routes.routeOtp,
            arguments: {
              'verificationId': verificationId,
              'selectedRole': role,
              'phoneNumber': phoneNumber,
            },
          );
        },
        onError: (err) {
          debugPrint('❌ ERROR SENDING OTP: $err');
          if (!mounted) return;
          _showSnackbar('Failed to send OTP: $err');
        },
        onAutoVerified: (user) {
          if (user != null) {
            debugPrint('🎉 AUTO-VERIFIED!');
            debugPrint('User ID: ${user.uid}');
            if (!mounted) return;
            Navigator.pushReplacementNamed(
              context,
              Routes.routeComplete,
              arguments: {
                'phoneNumber': phoneNumber,
                'role': role,
              },
            );
          } else {
            debugPrint('🔔 Auto-verify reported null user');
          }
        },
      );
    } catch (e) {
      debugPrint('💥 EXCEPTION IN SEND OTP: $e');
      if (mounted) _showSnackbar('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void _showSnackbar(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget roleCard(String key, String label, String subtitle, IconData icon) {
    final selected = role == key;
    final color = key == 'farmer' ? farmerGreen : buyerBlue;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => role = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? color.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: selected ? 12 : 6,
                offset: Offset(0, selected ? 6 : 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: selected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = role == 'farmer' ? farmerGreen : buyerBlue;

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Phone Verification',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phone number section
                const Text(
                  '📱 Enter your phone number',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We\'ll send you a verification code',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone input
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: const Text(
                        '+91',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Phone number',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: currentColor, width: 2),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Role selection
                const Text(
                  'I am a:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    roleCard('farmer', 'Farmer', 'Sell Produce', Icons.agriculture),
                    roleCard('buyer', 'Buyer', 'Buy Produce', Icons.shopping_cart),
                  ],
                ),

                const Spacer(),

                // Web warning
                if (kIsWeb)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Web requires Firebase reCAPTCHA setup to send real OTPs.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Send OTP button
                _AnimatedButton(
                  text: 'Send OTP',
                  color: currentColor,
                  isLoading: sending,
                  onPressed: sending ? null : _sendOtp,
                  icon: Icons.arrow_forward_rounded,
                ),

                const SizedBox(height: 12),

                // Skip button
                _AnimatedButton(
                  text: 'Skip & Open Scrollable Views',
                  color: Colors.blue,
                  isLoading: false,
                  onPressed: () {
                    Navigator.pushNamed(context, '/scrollable');
                  },
                  icon: Icons.skip_next_rounded,
                  isSecondary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String text;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isSecondary;

  const _AnimatedButton({
    required this.text,
    required this.color,
    required this.isLoading,
    required this.onPressed,
    required this.icon,
    this.isSecondary = false,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 52,
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.shade300
              : (widget.isSecondary
              ? widget.color.withOpacity(0.1)
              : widget.color),
          borderRadius: BorderRadius.circular(10),
          border: widget.isSecondary
              ? Border.all(color: widget.color.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: _isPressed || isDisabled
              ? []
              : [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.isSecondary ? widget.color : Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.icon,
                color: widget.isSecondary ? widget.color : Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}