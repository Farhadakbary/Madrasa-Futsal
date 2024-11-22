import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({Key? key}) : super(key: key);

  void _shareApp() {
    Share.share(
      'Hey! Check out this amazing app: https://example.com',
      subject: 'Amazing App!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share App'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // نمایش دکمه اشتراک‌گذاری
            ElevatedButton.icon(
              onPressed: _shareApp, // فراخوانی متد اشتراک‌گذاری
              icon: const Icon(Icons.share),
              label: const Text('Share App'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
