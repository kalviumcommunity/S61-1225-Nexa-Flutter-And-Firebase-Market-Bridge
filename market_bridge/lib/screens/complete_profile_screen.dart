import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'responsive_home.dart';

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
  bool loading = false;

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final location = locationController.text.trim();

    if (name.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter required fields')));
      return;
    }

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? FirebaseFirestore.instance.collection('users').doc().id;

    final Map<String, dynamic> data = {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': widget.phoneNumber,
      'location': location,
      'preferredLanguage': preferredLanguage,
      'farmSize': farmSizeController.text.trim(),
      'role': widget.role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(data, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));

      // navigate to home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResponsiveHome()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() => loading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: const Color(0xFF11823F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 6),
            const Icon(Icons.person_pin, size: 56, color: Colors.orange),
            const SizedBox(height: 8),
            const Text('Complete Your Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 18),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email (optional)", border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: preferredLanguage,
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                DropdownMenuItem(value: 'Local', child: Text('Local')),
              ],
              onChanged: (v) => setState(() => preferredLanguage = v ?? 'English'),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Preferred Language'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: farmSizeController,
              decoration: const InputDecoration(labelText: "Farm Size (optional)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11823F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Complete Registration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
