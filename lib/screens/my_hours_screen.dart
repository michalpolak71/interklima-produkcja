import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants.dart';
import '../services/work_session_provider.dart';

class MyHoursScreen extends StatefulWidget {
  const MyHoursScreen({super.key});

  @override
  State<MyHoursScreen> createState() => _MyHoursScreenState();
}

class _MyHoursScreenState extends State<MyHoursScreen> {
  double _hours = 0;
  int _target = 0;
  int _days = 0;
  int _workDays = 0;
  int _month = 0;
  bool _loading = true;

  static const List<String> _monthNames = [
    '', 'Stycze\u0144', 'Luty', 'Marzec', 'Kwiecie\u0144', 'Maj', 'Czerwiec',
    'Lipiec', 'Sierpie\u0144', 'Wrzesie\u0144', 'Pa\u017adziernik', 'Listopad', 'Grudzie\u0144'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final phone = Provider.of<WorkSessionProvider>(context, listen: false).userPhone ?? '';
    try {
      final resp = await http.get(Uri.parse('${AppConstants.webhookUrl}?action=MOJE_GODZINY&phone=$phone')).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200 && resp.body.contains('"hours"')) {
        final data = jsonDecode(resp.body);
        _hours = (data['hours'] ?? 0).toDouble();
        _target = (data['target'] ?? 0).toInt();
        _days = (data['days'] ?? 0).toInt();
        _workDays = (data['workDays'] ?? 0).toInt();
        _month = (data['month'] ?? 0).toInt();
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _target > 0 ? (_hours / _target).clamp(0.0, 1.5) : 0.0;
    final progressClamped = progress.clamp(0.0, 1.0);
    final isGood = _hours >= _target * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje godziny'),
        backgroundColor: const Color(0xFF1B2838),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 20),
                Text(
                  _month > 0 && _month <= 12 ? _monthNames[_month] : '',
                  style: const TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 2),
                ),
                const SizedBox(height: 24),

                // Duzy licznik
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: (isGood ? Colors.green : Colors.orange).withOpacity(0.15),
                      blurRadius: 30, spreadRadius: 2)],
                  ),
                  child: Column(children: [
                    Text(
                      '${_hours.toStringAsFixed(1)} / $_target h',
                      style: TextStyle(
                        color: isGood ? Colors.green : Colors.orange,
                        fontSize: 36, fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressClamped.toDouble(),
                        minHeight: 12,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(isGood ? Colors.green : Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: isGood ? Colors.green : Colors.orange, fontSize: 14),
                    ),
                  ]),
                ),
                const SizedBox(height: 32),

                // Statystyki
                Row(children: [
                  _statCard('Dni przepracowane', '$_days', Icons.calendar_today),
                  const SizedBox(width: 12),
                  _statCard('Dni robocze', '$_workDays', Icons.work),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _statCard('Przepracowano', '${_hours.toStringAsFixed(1)}h', Icons.timer),
                  const SizedBox(width: 12),
                  _statCard('Pozosta\u0142o', '${(_target - _hours).clamp(0, 9999).toStringAsFixed(1)}h', Icons.hourglass_bottom),
                ]),
              ]),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
