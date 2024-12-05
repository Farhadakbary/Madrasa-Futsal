import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({Key? key}) : super(key: key);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

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
        title: const Text('Share App',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline,color: Colors.white,),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: ElevatedButton.icon(
                  onPressed: _shareApp,
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    'Share App',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    backgroundColor: Colors.blue.shade700,
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Share via Social Media',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShareIcon(
                    icon: const Icon(FontAwesomeIcons.facebook),
                    label: 'Facebook',
                    onTap: () => _shareSocialMedia('Facebook'),
                  ),
                  const SizedBox(width: 30),
                  _buildShareIcon(
                    icon: const Icon(FontAwesomeIcons.whatsapp),
                    label: 'WhatsApp',
                    onTap: () => _shareSocialMedia('WhatsApp'),
                  ),
                  const SizedBox(width: 30),
                  _buildShareIcon(
                    icon: const Icon(FontAwesomeIcons.twitter),
                    label: 'Twitter',
                    onTap: () => _shareSocialMedia('Twitter'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildAnimatedIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareIcon({
    required Icon icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            child: Icon(
              icon.icon,
              size: 50,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _animation,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _shareSocialMedia(String platform) {
    Share.share(
      'Check this out on $platform: https://example.com',
      subject: 'Shared via $platform',
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Icon(
          Icons.send,
          size: 80,
          color: Colors.blue.shade500,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller
        .dispose();
    super.dispose();
  }
}
