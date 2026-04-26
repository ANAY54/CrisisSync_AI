import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'staff_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1014),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Row(
                children: [
                  Icon(Icons.crisis_alert, color: Color(0xFFFF4D4D), size: 28),
                  SizedBox(width: 10),
                  Text('CrisisSync AI',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Select your role to continue',
                  style:
                      TextStyle(fontSize: 15, color: Color(0xFF9AA4AF))),
              const SizedBox(height: 48),
              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Reporter',
                subtitle:
                    'Report an emergency incident\nand get instant AI response',
                color: const Color(0xFFFF4D4D),
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                icon: Icons.shield_rounded,
                title: 'Staff / Responder',
                subtitle:
                    'View assigned incidents\nand manage response status',
                color: const Color(0xFF42D392),
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const StaffScreen())),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Powered by Gemini AI + Firebase',
                  style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF9AA4AF).withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF151C22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9AA4AF),
                          height: 1.5)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.6), size: 18),
          ],
        ),
      ),
    );
  }
}