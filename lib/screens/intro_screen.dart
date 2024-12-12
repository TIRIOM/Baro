import 'package:flutter/material.dart';
import 'usage_guide_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 소개 이미지
            const Icon(
              Icons.map,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            // 소개 텍스트
            const Text(
              '자판기에서 Baro 헬멧을\n대여할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UsageGuideScreen()),
                );
              },
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
