import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'worker_pings_screen.dart';

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  List<Map<String, String>> _workers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final resp = await http.get(Uri.parse('${AppConstants.webhookUrl}?action=LISTA_PRACOWNIKOW')).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200 && resp.body.contains('"workers"')) {
        final data = jsonDecode(resp.body);
        final list = data['workers'] as List;
        _workers = list.map((r) => Map<String, String>.from(
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
        title: const Text('Pracownicy - lokalizacja'),
        backgroundColor: const Color(0xFF1B2838),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : _workers.isEmpty
              ? const Center(child: Text('Brak pracownik\u00f3w', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _workers.length,
                  itemBuilder: (ctx, i) {
                    final w = _workers[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1B3A5C),
                          child: Icon(Icons.person, color: Colors.white70),
                        ),
                        title: Text(w['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text(w['phone'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => WorkerPingsScreen(
                              workerPhone: w['phone'] ?? '',
                              workerName: w['name'] ?? '',
                            ),
                          ));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
