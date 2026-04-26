import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'feedback_screen.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  String _currentStatus = 'Assigned';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.data['status'] ?? 'Assigned';
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Color _severityColor(String? s) {
    switch (s) {
      case 'High': return const Color(0xFFFF4D4D);
      case 'Medium': return const Color(0xFFF6C343);
      default: return const Color(0xFF42D392);
    }
  }

  Color _typeColor(String? t) {
    switch (t) {
      case 'Fire': return const Color(0xFFFF4D4D);
      case 'Medical': return const Color(0xFF4D9FFF);
      case 'Security': return const Color(0xFFF6C343);
      default: return const Color(0xFF9AA4AF);
    }
  }

  IconData _typeIcon(String? t) {
    switch (t) {
      case 'Fire': return Icons.local_fire_department;
      case 'Medical': return Icons.medical_services;
      case 'Security': return Icons.security;
      default: return Icons.report_problem;
    }
  }

  void _updateStatus(String status) async {
    final id = widget.data['id'];
    if (id == null) return;
    try {
      await ApiService.updateStatus(id, status);
      setState(() => _currentStatus = status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Status updated to $status'),
        backgroundColor: const Color(0xFF42D392),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Update failed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions =
        List<String>.from(widget.data['suggestions'] ?? []);
    final severity = widget.data['severity'] as String?;
    final type = widget.data['type'] as String?;
    final sColor = _severityColor(severity);
    final tColor = _typeColor(type);
    final assignedTo =
        widget.data['assigned_to'] ?? 'Response Team';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151C22),
        elevation: 0,
        title: const Text('Incident Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: sColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sColor, width: 1),
            ),
            child: Text(severity ?? '',
                style: TextStyle(
                    color: sColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnim,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151C22),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: tColor.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: tColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_typeIcon(type), color: tColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type ?? 'Unknown',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: tColor)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 13, color: Color(0xFF9AA4AF)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.data['location'] ?? 'Unknown',
                                style: const TextStyle(
                                    color: Color(0xFF9AA4AF),
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Staff assigned card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151C22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF42D392).withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF42D392).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Color(0xFF42D392), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ASSIGNED RESPONDER',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9AA4AF),
                                letterSpacing: 1)),
                        const SizedBox(height: 3),
                        Text(assignedTo,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF42D392))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statusColor(_currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _statusColor(_currentStatus)
                              .withOpacity(0.4)),
                    ),
                    child: Text(_currentStatus,
                        style: TextStyle(
                            fontSize: 11,
                            color: _statusColor(_currentStatus),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // AI Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151C22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI ANALYSIS',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9AA4AF),
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Text(widget.data['summary'] ?? '',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action steps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151C22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RECOMMENDED ACTIONS',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9AA4AF),
                          letterSpacing: 1)),
                  const SizedBox(height: 14),
                  ...suggestions.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: const Color(0xFF42D392)
                                    .withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('${e.key + 1}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF42D392),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      height: 1.4)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status update buttons
            if (widget.data['id'] != null &&
                _currentStatus != 'Resolved') ...[
              Row(
                children: [
                  Expanded(
                    child: _statusButton(
                      'Responding',
                      Icons.directions_run,
                      const Color(0xFFF6C343),
                      _currentStatus == 'Responding',
                      () => _updateStatus('Responding'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statusButton(
                      'Resolved',
                      Icons.check_circle,
                      const Color(0xFF42D392),
                      false,
                      () => _updateStatus('Resolved'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Feedback button
            if (widget.data['id'] != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FeedbackScreen(
                            incidentId: widget.data['id']))),
                icon: const Icon(Icons.star_outline,
                    color: Color(0xFFF6C343), size: 18),
                label: const Text('Rate Response Quality',
                    style: TextStyle(color: Color(0xFFF6C343))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xFFF6C343), width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'Resolved': return const Color(0xFF42D392);
      case 'Responding': return const Color(0xFFF6C343);
      default: return const Color(0xFF4D9FFF);
    }
  }

  Widget _statusButton(String label, IconData icon, Color color,
      bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active
              ? color.withOpacity(0.2)
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? color : color.withOpacity(0.3),
              width: active ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}