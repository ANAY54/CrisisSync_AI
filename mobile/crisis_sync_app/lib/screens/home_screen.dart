import 'package:flutter/material.dart';
import 'report_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ReportScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF151C22),
          border: Border(top: BorderSide(color: Color(0xFF263040), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: const Color(0xFF151C22),
          selectedItemColor: const Color(0xFFFF4D4D),
          unselectedItemColor: const Color(0xFF9AA4AF),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
          ],
        ),
      ),
    );
  }
}