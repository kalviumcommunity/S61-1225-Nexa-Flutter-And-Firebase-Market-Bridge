import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  State<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends State<CompleteProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final farmSizeController = TextEditingController();

  String preferredLanguage = 'English';
  String farmSizeUnit = 'Acres';
  bool loading = false;

  Color get themeColor =>
      widget.role.toLowerCase() == 'buyer'
          ? const Color(0xFF2196F3)
          : const Color(0xFF11823F);

  IconData get roleIcon =>
      widget.role.toLowerCase() == 'buyer'
          ? Icons.shopping_bag
          : Icons.agriculture;

  Color get iconBgColor =>
      widget.role.toLowerCase() == 'buyer'
          ? const Color(0xFFE3F2FD)
          : const Color(0xFFFFF3E0);

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter required fields')),
      );
      return;
    }

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ??
        FirebaseFirestore.instance.collection('users').doc().id;

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

    if (widget.role.toLowerCase() == 'farmer' &&
        farmSizeController.text.isNotEmpty) {
      data['farmSize'] =
          '${farmSizeController.text.trim()} $farmSizeUnit';
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      if (!mounted) return;

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile')),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: themeColor.withOpacity(0.1),
                child:
                    Icon(Icons.check, size: 40, color: themeColor),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registration Successful!',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Your ${widget.role} profile has been created.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                  child: const Text('Continue'),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = isTablet ? 48.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Complete Profile'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 520 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: isTablet ? 48 : 40,
                        backgroundColor: iconBgColor,
                        child: Icon(roleIcon,
                            size: isTablet ? 44 : 36,
                            color: themeColor),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Complete Your Profile',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: nameController,
                        label: 'Full Name',
                        hint: 'Enter your name',
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'email@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: locationController,
                        label: 'Location',
                        hint: 'City, District',
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      _buildLanguageDropdown(),
                      const SizedBox(height: 20),

                      if (widget.role.toLowerCase() == 'farmer')
                        _buildFarmSize(),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text('Complete Registration'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonFormField<String>(
      value: preferredLanguage,
      items: const [
        DropdownMenuItem(value: 'English', child: Text('English')),
        DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
        DropdownMenuItem(value: 'Local', child: Text('Local')),
      ],
      onChanged: (v) => setState(() => preferredLanguage = v!),
      decoration: const InputDecoration(
        labelText: 'Preferred Language',
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFarmSize() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: farmSizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Farm Size',
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: farmSizeUnit,
          items: const [
            DropdownMenuItem(value: 'Acres', child: Text('Acres')),
            DropdownMenuItem(value: 'Hectares', child: Text('Ha')),
          ],
          onChanged: (v) => setState(() => farmSizeUnit = v!),
        ),
      ],
    );
  }
}
