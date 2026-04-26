import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'processing_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedType = '';

  final List<Map<String, dynamic>> _quickTypes = [
    {'label': 'Fire', 'icon': Icons.local_fire_department, 'color': Color(0xFFFF4D4D)},
    {'label': 'Medical', 'icon': Icons.medical_services, 'color': Color(0xFF4D9FFF)},
    {'label': 'Security', 'icon': Icons.security, 'color': Color(0xFFF6C343)},
    {'label': 'Other', 'icon': Icons.report_problem, 'color': Color(0xFF9AA4AF)},
  ];

  void _quickFill(String type) {
    setState(() => _selectedType = type);
    _controller.text = '$type emergency reported. ';
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  void _submit() {
    if (_controller.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the incident first.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(description: _controller.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D4D).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.crisis_alert, color: Color(0xFFFF4D4D), size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CrisisSync AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Emergency Response Platform', style: TextStyle(fontSize: 12, color: Color(0xFF9AA4AF))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('Quick Report', style: TextStyle(fontSize: 13, color: Color(0xFF9AA4AF), letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Row(
                children: _quickTypes.map((t) {
                  final selected = _selectedType == t['label'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _quickFill(t['label']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? (t['color'] as Color).withOpacity(0.2)
                              : const Color(0xFF151C22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? t['color'] as Color : const Color(0xFF263040),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(t['icon'] as IconData, color: t['color'] as Color, size: 22),
                            const SizedBox(height: 4),
                            Text(t['label'] as String,
                                style: TextStyle(fontSize: 11, color: t['color'] as Color)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Describe the Incident', style: TextStyle(fontSize: 13, color: Color(0xFF9AA4AF), letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151C22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF263040)),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Guest fainted near the pool area and is not responding...',
                    hintStyle: TextStyle(color: Color(0xFF9AA4AF), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (_, val, __) => Text(
                    '${val.text.length} chars',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9AA4AF)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.bolt, color: Colors.white),
                  label: const Text('Analyze Emergency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D4D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}