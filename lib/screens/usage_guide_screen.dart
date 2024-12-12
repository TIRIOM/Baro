import 'package:flutter/material.dart';
import 'map_screen.dart';

class UsageGuideScreen extends StatelessWidget {
  const UsageGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 40),
            const Text(
              '이용 방법',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            _buildGuideStep('1. 회원가입 후 크레딧을 확인해주세요'),
            _buildGuideStep('2. 지도에서 가까운 자판기를 확인하세요'),
            _buildGuideStep('3. 50m 이내에서만 대여/반납이 가능합니다'),
            _buildGuideStep('4. 대여 시 크레딧 10이 차감됩니다'),
            _buildGuideStep('5. 반납은 모든 자판기에서 가능합니다'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
