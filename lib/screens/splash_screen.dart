import 'package:flutter/material.dart';
import 'intro_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/helmet.png',
              width: screenHeight * 0.4,
              height: screenHeight * 0.4,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'Baro',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'PM문화를 올바로',
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const IntroScreen()),
                );
              },
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}
