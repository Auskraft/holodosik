import 'package:flutter/material.dart';

import '../features/shell/app_shell.dart';

/// Внутренний сплеш: на Android 12+ системный сплеш показывает только заливку
/// фона, поэтому красивую картинку выводим сами на старте.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Фон бренда — совпадает с цветом нативного сплеша (flutter_native_splash).
  static const Color _brandBackground = Color(0xFFF9A826);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _brandBackground,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/icon/splash.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
