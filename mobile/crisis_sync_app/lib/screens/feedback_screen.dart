import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  final String incidentId;
  const FeedbackScreen({super.key, required this.incidentId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  bool _responseAdequate = true;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  void _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiService.submitFeedback(
        incidentId: widget.incidentId,
        rating: _rating,
        comment: _commentController.text,
        responseAdequate: _responseAdequate,
      );
      setState(() { _submitted = true; _submitting = false; });
    } catch (_) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit feedback.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151C22),
        title: const Text('Incident Feedback'),
      ),
      body: _submitted ? _thankYouView() : _formView(),
    );
  }

  Widget _thankYouView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF42D392), size: 72),
          const SizedBox(height: 16),
          const Text('Feedback Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Thank you for helping us improve.', style: TextStyle(color: Color(0xFF9AA4AF))),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back', style: TextStyle(color: Color(0xFFFF4D4D))),
          ),
        ],
      ),
    );
  }

  Widget _formView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('How was the response?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        const Text('Your feedback improves future response quality.', style: TextStyle(color: Color(0xFF9AA4AF))),
        const SizedBox(height: 24),

        // Star Rating
        const Text('RATING', style: TextStyle(fontSize: 12, color: Color(0xFF9AA4AF), letterSpacing: 1)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  i < _rating ? Icons.star : Icons.star_outline,
                  color: const Color(0xFFF6C343),
                  size: 40,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Was response adequate
        const Text('RESPONSE QUALITY', style: TextStyle(fontSize: 12, color: Color(0xFF9AA4AF), letterSpacing: 1)),
        const SizedBox(height: 12),
        Row(
          children: [
            _toggleChip('Adequate', true),
            const SizedBox(width: 12),
            _toggleChip('Needs Improvement', false),
          ],
        ),
        const SizedBox(height: 24),

        // Comment
        const Text('ADDITIONAL COMMENTS', style: TextStyle(fontSize: 12, color: Color(0xFF9AA4AF), letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151C22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF263040)),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Any additional comments...',
              hintStyle: TextStyle(color: Color(0xFF9AA4AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _submitting
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _toggleChip(String label, bool value) {
    final selected = _responseAdequate == value;
    return GestureDetector(
      onTap: () => setState(() => _responseAdequate = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF42D392).withOpacity(0.1) : const Color(0xFF151C22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF42D392) : const Color(0xFF263040)),
        ),
        child: Text(label, style: TextStyle(color: selected ? const Color(0xFF42D392) : const Color(0xFF9AA4AF), fontSize: 13)),
      ),
    );
  }
}