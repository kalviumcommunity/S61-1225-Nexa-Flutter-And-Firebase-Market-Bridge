import 'package:flutter/material.dart';

class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stateless & Stateful Demo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: DemoBody(),   // <- Stateful widget BELOW
      ),
    );
  }
}

class DemoBody extends StatefulWidget {
  const DemoBody({super.key});

  @override
  State<DemoBody> createState() => _DemoBodyState();
}

class _DemoBodyState extends State<DemoBody> {
  int counter = 0;
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Counter: $counter",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        // Counter button
        ElevatedButton(
          onPressed: () {
            setState(() => counter++);
          },
          child: const Text("Increase Counter"),
        ),

        const SizedBox(height: 30),

        // Toggle button
        ElevatedButton(
          onPressed: () {
            setState(() => isDark = !isDark);
          },
          child: Text(isDark ? "Switch to Light Mode" : "Switch to Dark Mode"),
        ),

        const SizedBox(height: 20),

        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.yellow,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}
