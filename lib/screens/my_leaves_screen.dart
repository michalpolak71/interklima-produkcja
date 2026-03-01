import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants.dart';
import '../services/work_session_provider.dart';

class MyLeavesScreen extends StatefulWidget {
  const MyLeavesScreen({super.key});

  @override
  State<MyLeavesScreen> createState() => _MyLeavesScreenState();
}

class _MyLeavesScreenState extends State<MyLeavesScreen> {
  List<Map<String, String>> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final phone = Provider.of<WorkSessionProvider>(context, listen: false).userPhone ?? '';
    try {
      final resp = await http.get(Uri.parse('${AppConstants.webhookUrl}?action=MOJE_URLOPY&phone=$phone')).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200 && resp.body.contains('"requests"')) {
        final data = jsonDecode(resp.body);
        final list = data['requests'] as List;
        _requests = list.map((r) => Map<String, String>.from(
          (r as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
        )).toList();
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje wnioski'),
        backgroundColor: const Color(0xFF1B2838),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : _requests.isEmpty
              ? const Center(child: Text('Brak wniosk\u00f3w', style: TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (ctx, i) => _buildCard(_requests[_requests.length - 1 - i]),
                ),
    );
  }

  Widget _buildCard(Map<String, String> req) {
    final status = (req['status'] ?? 'NOWY').toUpperCase();
    final isApproved = status.contains('ZATW');
    final isRejected = status.contains('ODRZ');
    Color col = Colors.orange;
    IconData ico = Icons.hourglass_top;
    if (isApproved) { col = Colors.green; ico = Icons.check_circle; }
    if (isRejected) { col = Colors.red; ico = Icons.cancel; }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: col.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(ico, color: col, size: 20),
          const SizedBox(width: 8),
          Text(status, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          Text(req['data'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text(req['typ'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${req['od'] ?? ''} - ${req['do'] ?? ''}  (${req['dni'] ?? '?'} dni)',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        if (req['uwagi'] != null && req['uwagi']!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(req['uwagi']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ),
      ]),
    );
  }
}
