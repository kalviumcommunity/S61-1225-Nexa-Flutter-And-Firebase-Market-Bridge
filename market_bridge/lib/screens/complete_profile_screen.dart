import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'responsive_home.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection("users").doc().set({
                  "name": nameController.text.trim(),
                  "location": locationController.text.trim(),
                });

                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const ResponsiveHome()));
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
