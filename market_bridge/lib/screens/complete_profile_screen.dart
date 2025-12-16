// lib/screens/complete_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String phoneNumber;
  final String role; // farmer or buyer

  const CompleteProfileScreen({Key? key, required this.phoneNumber, required this.role}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  String preferredLanguage = 'English';
  final farmSizeController = TextEditingController();
  String farmSizeUnit = 'Acres';
  bool loading = false;

  // Helper method to get theme color based on role
  Color get themeColor {
    return widget.role.toLowerCase() == 'buyer'
        ? const Color(0xFF2196F3)
        : const Color(0xFF11823F);
  }

  // Helper method to get icon based on role
  IconData get roleIcon {
    return widget.role.toLowerCase() == 'buyer'
        ? Icons.shopping_bag
        : Icons.agriculture;
  }

  // Helper method to get icon background color based on role
  Color get iconBgColor {
    return widget.role.toLowerCase() == 'buyer'
        ? const Color(0xFFE3F2FD)
        : const Color(0xFFFFF3E0);
  }

  void _showSuccessDialog(BuildContext context, Color themeColor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: themeColor,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Registration Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your ${widget.role.toLowerCase()} profile has been created successfully. Welcome to Market Bridge!',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to appropriate home screen based on role
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.routeHome,
                            (route) => false,
                        arguments: {'role': widget.role},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final location = locationController.text.trim();

    debugPrint('==========================================');
    debugPrint('💾 SAVING PROFILE');
    debugPrint('Name: $name');
    debugPrint('Email: $email');
    debugPrint('Location: $location');
    debugPrint('Language: $preferredLanguage');
    debugPrint('Farm Size: ${farmSizeController.text} $farmSizeUnit');
    debugPrint('Role: ${widget.role}');
    debugPrint('==========================================');

    if (name.isEmpty || location.isEmpty) {
      debugPrint('❌ Validation failed: Missing required fields');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter required fields')));
      return;
    }

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;
    debugPrint('👤 User UID: $uid');
    final farmSizeValue = farmSizeController.text.trim();
    final farmSizeComplete = farmSizeValue.isNotEmpty ? '$farmSizeValue $farmSizeUnit' : '';

    final Map<String, dynamic> data = {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': widget.phoneNumber,
      'location': location,
      'preferredLanguage': preferredLanguage,
      'role': widget.role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add farmSize only if role is farmer
    if (widget.role.toLowerCase() == 'farmer') {
      data['farmSize'] = farmSizeComplete;
    }

    try {
      debugPrint('🔄 Saving to Firestore...');
      await FirebaseFirestore.instance.collection('users').doc(uid).set(data, SetOptions(merge: true));
      debugPrint('✅ PROFILE SAVED SUCCESSFULLY');
      debugPrint('Document ID: $uid');

      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            debugPrint('📱 Showing success dialog');
            _showSuccessDialog(context, themeColor);
          }
        });
      }
    } catch (e) {
      debugPrint('💥 ERROR SAVING PROFILE: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $e'))
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFarmer = widget.role.toLowerCase() == 'farmer';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Role-based icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Icon(
                    roleIcon,
                    size: 40,
                    color: themeColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Help us serve you better',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 32),

              // Full Name field
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                isRequired: true,
              ),
              const SizedBox(height: 20),

              // Email Address field
              _buildTextField(
                controller: emailController,
                label: 'Email Address',
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Location field
              _buildTextField(
                controller: locationController,
                label: 'Location',
                hint: 'City, District',
                isRequired: true,
              ),
              const SizedBox(height: 20),

              // Preferred Language dropdown
              _buildDropdown(),
              const SizedBox(height: 20),

              // Farm Size field (only for farmers)
              if (isFarmer) ...[
                _buildFarmSizeField(),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 12),

              // Complete Registration button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    disabledBackgroundColor: themeColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
            children: [
              TextSpan(text: '$label '),
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
            children: [
              TextSpan(text: 'Preferred Language '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: preferredLanguage,
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
            DropdownMenuItem(value: 'Local', child: Text('Local')),
          ],
          onChanged: (v) => setState(() => preferredLanguage = v ?? 'English'),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildFarmSizeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farm Size (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: farmSizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Area',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: themeColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: farmSizeUnit,
                items: const [
                  DropdownMenuItem(value: 'Acres', child: Text('Acres')),
                  DropdownMenuItem(value: 'Hectares', child: Text('Ha')),
                ],
                onChanged: (v) => setState(() => farmSizeUnit = v ?? 'Acres'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: themeColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF666666)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}