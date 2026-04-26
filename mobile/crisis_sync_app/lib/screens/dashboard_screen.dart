import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Live Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF42D392),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            // Stats row
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('incidents').snapshots(),
              builder: (context, snap) {
                final docs = snap.data?.docs ?? [];
                final active = docs.where((d) => (d.data() as Map)['status'] != 'Resolved').length;
                final resolved = docs.length - active;
                final high = docs.where((d) => (d.data() as Map)['severity'] == 'High').length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _statChip('Active', '$active', const Color(0xFFFF4D4D)),
                      const SizedBox(width: 8),
                      _statChip('Resolved', '$resolved', const Color(0xFF42D392)),
                      const SizedBox(width: 8),
                      _statChip('High Risk', '$high', const Color(0xFFF6C343)),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('incidents')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4D4D)));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF42D392), size: 56),
                          SizedBox(height: 12),
                          Text('No active incidents', style: TextStyle(color: Color(0xFF9AA4AF), fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final severity = d['severity'] as String?;
                      final sColor = _severityColor(severity);
                      final status = d['status'] as String?;
                      final stColor = _statusColor(status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151C22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: sColor.withOpacity(0.25)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: sColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              d['type'] == 'Fire' ? Icons.local_fire_department
                                  : d['type'] == 'Medical' ? Icons.medical_services
                                  : Icons.security,
                              color: sColor,
                              size: 22,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(d['type'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(severity ?? '', style: TextStyle(fontSize: 11, color: sColor)),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(d['location'] ?? '', style: const TextStyle(color: Color(0xFF9AA4AF), fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 12, color: stColor),
                                  const SizedBox(width: 4),
                                  Text(d['assigned_to'] ?? '', style: TextStyle(fontSize: 12, color: stColor)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: stColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(status ?? '', style: TextStyle(fontSize: 11, color: stColor)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA4AF))),
          ],
        ),
      ),
    );
  }
}