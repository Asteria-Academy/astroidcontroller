// lib/screens/home_screen.dart
import 'package:astroidcontroller/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.smart_toy_outlined,
              size: 120,
              color: Colors.cyanAccent,
            ),
            const SizedBox(height: 10),
            const Text(
              'Astroid Remote',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Your companion robot's command center",
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(178, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 60),

            ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Connect to Robot'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.connect);
              },
            ),
            const SizedBox(height: 20),

            // Debug bypass button
            OutlinedButton.icon(
              icon: const Icon(Icons.developer_mode, size: 18),
              label: const Text('Skip to Control (Debug)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber,
                side: const BorderSide(color: Colors.amber),
                minimumSize: const Size(250, 50),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.remoteControl);
              },
            ),
          ],
        ),
      ),
    );
  }
}
