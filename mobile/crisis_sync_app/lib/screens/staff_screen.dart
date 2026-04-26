import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import 'role_select_screen.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  Color _severityColor(String? s) {
    switch (s) {
      case 'High': return const Color(0xFFFF4D4D);
      case 'Medium': return const Color(0xFFF6C343);
      default: return const Color(0xFF42D392);
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'Resolved': return const Color(0xFF42D392);
      case 'Responding': return const Color(0xFFF6C343);
      default: return const Color(0xFF4D9FFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1014),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF151C22),
                border: Border(
                    bottom: BorderSide(color: Color(0xFF263040))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF42D392).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: Color(0xFF42D392), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Staff Dashboard',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text('Live incident feed',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF9AA4AF))),
                    ],
                  ),
                  const Spacer(),
                  // Live indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF42D392).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF42D392).withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle,
                            color: Color(0xFF42D392), size: 8),
                        SizedBox(width: 5),
                        Text('LIVE',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF42D392),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats bar
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('incidents')
                  .snapshots(),
              builder: (context, snap) {
                final docs = snap.data?.docs ?? [];
                final active = docs
                    .where((d) =>
                        (d.data() as Map)['status'] != 'Resolved')
                    .length;
                final high = docs
                    .where(
                        (d) => (d.data() as Map)['severity'] == 'High')
                    .length;
                final resolved = docs.length - active;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  color: const Color(0xFF0F1923),
                  child: Row(
                    children: [
                      _stat('Active', '$active', const Color(0xFFFF4D4D)),
                      _divider(),
                      _stat('High Risk', '$high',
                          const Color(0xFFF6C343)),
                      _divider(),
                      _stat('Resolved', '$resolved',
                          const Color(0xFF42D392)),
                      _divider(),
                      _stat('Total', '${docs.length}',
                          const Color(0xFF9AA4AF)),
                    ],
                  ),
                );
              },
            ),

            // Incident list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('incidents')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFF4D4D)));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: const Color(0xFF42D392)
                                  .withOpacity(0.5),
                              size: 64),
                          const SizedBox(height: 16),
                          const Text('No incidents reported',
                              style: TextStyle(
                                  color: Color(0xFF9AA4AF),
                                  fontSize: 16)),
                          const Text('All clear!',
                              style: TextStyle(
                                  color: Color(0xFF9AA4AF),
                                  fontSize: 13)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final d =
                          docs[i].data() as Map<String, dynamic>;
                      final id = docs[i].id;
                      final severity = d['severity'] as String?;
                      final status = d['status'] as String?;
                      final sColor = _severityColor(severity);
                      final stColor = _statusColor(status);
                      final isResolved = status == 'Resolved';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151C22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: sColor.withOpacity(
                                  isResolved ? 0.1 : 0.3)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: sColor.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          d['type'] == 'Fire'
                                              ? Icons
                                                  .local_fire_department
                                              : d['type'] == 'Medical'
                                                  ? Icons.medical_services
                                                  : Icons.security,
                                          color: sColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  d['type'] ?? 'Unknown',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isResolved
                                                          ? const Color(
                                                              0xFF9AA4AF)
                                                          : Colors.white),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: sColor
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(20),
                                                  ),
                                                  child: Text(
                                                    severity ?? '',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: sColor,
                                                        fontWeight:
                                                            FontWeight
                                                                .w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              d['location'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Color(0xFF9AA4AF)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              stColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: stColor
                                                  .withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          status ?? '',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: stColor,
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    d['summary'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9AA4AF),
                                        height: 1.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 13,
                                          color: Color(0xFF9AA4AF)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Assigned: ${d['assigned_to'] ?? 'Unassigned'}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9AA4AF)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Action buttons
                            if (!isResolved)
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Color(0xFF263040))),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _actionBtn(
                                        context,
                                        'Responding',
                                        Icons.directions_run,
                                        const Color(0xFFF6C343),
                                        status == 'Responding',
                                        () => _updateStatus(
                                            context, id, 'Responding'),
                                      ),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 48,
                                        color: const Color(0xFF263040)),
                                    Expanded(
                                      child: _actionBtn(
                                        context,
                                        'Resolved',
                                        Icons.check_circle,
                                        const Color(0xFF42D392),
                                        false,
                                        () => _updateStatus(
                                            context, id, 'Resolved'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom switch role
            GestureDetector(
              onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(
                      builder: (_) => const RoleSelectScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF151C22),
                  border:
                      Border(top: BorderSide(color: Color(0xFF263040))),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_horiz,
                        color: Color(0xFF9AA4AF), size: 16),
                    SizedBox(width: 8),
                    Text('Switch Role',
                        style: TextStyle(
                            color: Color(0xFF9AA4AF), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9AA4AF))),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 30, color: const Color(0xFF263040));
  }

  Widget _actionBtn(BuildContext context, String label, IconData icon,
      Color color, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _updateStatus(
      BuildContext context, String id, String status) async {
    try {
      await ApiService.updateStatus(id, status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Marked as $status'),
        backgroundColor: status == 'Resolved'
            ? const Color(0xFF42D392)
            : const Color(0xFFF6C343),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update'),
        backgroundColor: Colors.red,
      ));
    }
  }
}