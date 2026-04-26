import 'package:flutter/material.dart';
import 'role_select_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const RoleSelectScreen()));
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1014),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF4D4D)
                        .withOpacity(0.08 + _pulseController.value * 0.08),
                    border: Border.all(
                      color: const Color(0xFFFF4D4D)
                          .withOpacity(0.3 + _pulseController.value * 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.crisis_alert,
                      color: Color(0xFFFF4D4D), size: 52),
                ),
              ),
              const SizedBox(height: 28),
              const Text('CrisisSync AI',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('Rapid Crisis Response Platform',
                  style:
                      TextStyle(fontSize: 14, color: Color(0xFF9AA4AF))),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFFFF4D4D),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}