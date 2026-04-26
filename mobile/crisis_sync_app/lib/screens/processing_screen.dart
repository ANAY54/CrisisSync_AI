import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String description;
  const ProcessingScreen({super.key, required this.description});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  int _stepIndex = 0;

  final List<String> _steps = [
    'Receiving emergency report...',
    'Classifying incident type...',
    'Assessing severity level...',
    'Detecting location context...',
    'Assigning response team...',
    'Generating action plan...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _startProcess();
  }

  void _startProcess() async {
    // Step through UI states while API call happens
    for (int i = 0; i < _steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _stepIndex = i + 1);
    }

    try {
      final result = await ApiService.reportIncident(widget.description);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(data: result)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1014),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF4D4D).withOpacity(0.1 + _pulseController.value * 0.1),
                      border: Border.all(
                        color: const Color(0xFFFF4D4D).withOpacity(0.3 + _pulseController.value * 0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.crisis_alert, color: Color(0xFFFF4D4D), size: 48),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'AI Agents Processing',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Multi-agent analysis in progress',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9AA4AF)),
                ),
                const SizedBox(height: 40),
                ...List.generate(_steps.length, (i) {
                  final done = i < _stepIndex;
                  final active = i == _stepIndex;
                  return AnimatedOpacity(
                    opacity: i <= _stepIndex ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? const Color(0xFF42D392)
                                  : active
                                      ? const Color(0xFFFF4D4D)
                                      : const Color(0xFF263040),
                            ),
                            child: Icon(
                              done ? Icons.check : active ? Icons.circle : Icons.circle_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _steps[i],
                            style: TextStyle(
                              fontSize: 14,
                              color: active ? Colors.white : const Color(0xFF9AA4AF),
                              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}