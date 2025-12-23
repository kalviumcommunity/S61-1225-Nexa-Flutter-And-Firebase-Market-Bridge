// lib/screens/complete_profile_screen.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cloud_functions_service.dart';
import '../routes.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const CompleteProfileScreen({
    Key? key,
    required this.phoneNumber,
    required this.role,
  }) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final farmSizeController = TextEditingController();

  String preferredLanguage = 'English';
  String farmSizeUnit = 'Acres';
  bool loading = false;

  // Cloud Functions Service
  final _functionsService = CloudFunctionsService();

  Color get themeColor => widget.role.toLowerCase() == 'buyer'
      ? const Color(0xFF2196F3)
      : const Color(0xFF11823F);

  Color get themeLightColor => widget.role.toLowerCase() == 'buyer'
      ? const Color(0xFFE3F2FD)
      : const Color(0xFFE8F5E9);

  IconData get roleIcon => widget.role.toLowerCase() == 'buyer'
      ? Icons.shopping_bag_rounded
      : Icons.agriculture_rounded;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    farmSizeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;

    final data = {
      'uid': uid,
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': widget.phoneNumber,
      'location': locationController.text.trim(),
      'preferredLanguage': preferredLanguage,
      'role': widget.role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (widget.role.toLowerCase() == 'farmer' && farmSizeController.text.isNotEmpty) {
      data['farmSize'] = '${farmSizeController.text.trim()} $farmSizeUnit';
    }

    try {
      debugPrint('💾 Saving user profile...');

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ Profile saved to Firestore');

      // Call Cloud Function for welcome notification
      debugPrint('📞 Triggering welcome notification...');
      final result = await _functionsService.sendWelcomeNotification(
        userName: nameController.text.trim(),
        userRole: widget.role,
      );

      if (result != null) {
        debugPrint('✅ Welcome notification sent');
        debugPrint('Message: ${result['message']}');
      }

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeLightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, size: 48, color: themeColor),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registration Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Your ${widget.role} profile has been created.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.routeHome,
                          (_) => false,
                      arguments: {'role': widget.role},
                    );
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
    return Scaffold(
      backgroundColor: themeColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(roleIcon, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${widget.role}!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your profile to get started',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        isRequired: true,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: emailController,
                        label: 'Email Address',
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(v)) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: locationController,
                        label: 'Location',
                        hint: 'City, District',
                        icon: Icons.location_on_outlined,
                        isRequired: true,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your location'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLanguageDropdown(),

                      if (widget.role.toLowerCase() == 'farmer') ...[
                        const SizedBox(height: 16),
                        _buildFarmSize(),
                      ],

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: loading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: themeColor.withOpacity(0.6),
                            elevation: 0,
                            shadowColor: themeColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            'Complete Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: keyboardType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: themeColor, size: 22),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: const TextStyle(fontSize: 12, height: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Language',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: preferredLanguage,
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Hindi', child: Text('हिंदी (Hindi)')),
            DropdownMenuItem(value: 'Telugu', child: Text('తెలుగు (Telugu)')),
            DropdownMenuItem(value: 'Tamil', child: Text('தமிழ் (Tamil)')),
            DropdownMenuItem(value: 'Kannada', child: Text('ಕನ್ನಡ (Kannada)')),
          ],
          onChanged: (v) => setState(() => preferredLanguage = v!),
          icon: Icon(Icons.arrow_drop_down_rounded, color: themeColor, size: 28),
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.language_rounded, color: themeColor, size: 22),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFarmSize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farm Size (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: farmSizeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter size',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.landscape_rounded, color: themeColor, size: 22),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: themeColor, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: farmSizeUnit,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down_rounded, color: themeColor, size: 28),
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'Acres', child: Text('Acres')),
                      DropdownMenuItem(value: 'Hectares', child: Text('Hectares')),
                    ],
                    onChanged: (v) => setState(() => farmSizeUnit = v!),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}