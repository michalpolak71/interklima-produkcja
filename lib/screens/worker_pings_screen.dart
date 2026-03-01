import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class WorkerPingsScreen extends StatefulWidget {
  final String workerPhone;
  final String workerName;

  const WorkerPingsScreen({super.key, required this.workerPhone, required this.workerName});

  @override
  State<WorkerPingsScreen> createState() => _WorkerPingsScreenState();
}

class _WorkerPingsScreenState extends State<WorkerPingsScreen> {
  List<Map<String, String>> _pings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final resp = await http.get(Uri.parse('${AppConstants.webhookUrl}?action=PINGI&phone=${widget.workerPhone}')).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200 && resp.body.contains('"pings"')) {
        final data = jsonDecode(resp.body);
        final list = data['pings'] as List;
        _pings = list.map((r) => Map<String, String>.from(
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
        title: Text(widget.workerName),
        backgroundColor: const Color(0xFF1B2838),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : _pings.isEmpty
              ? const Center(child: Text('Brak danych', style: TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pings.length,
                  itemBuilder: (ctx, i) => _buildPingCard(_pings[i]),
                ),
    );
  }

  Widget _buildPingCard(Map<String, String> ping) {
    final type = ping['type'] ?? '';
    final alert = ping['alert'] ?? '';
    final hasAlert = alert.isNotEmpty;
    final lat = ping['lat'] ?? '';
    final lon = ping['lon'] ?? '';

    IconData icon;
    Color color;
    switch (type) {
      case 'START':
        icon = Icons.play_arrow; color = Colors.green;
        break;
      case 'STOP':
      case 'STOP_AUTO':
        icon = Icons.stop; color = Colors.red;
        break;
      case 'PING':
        icon = Icons.location_on; color = hasAlert ? Colors.orange : Colors.blue;
        break;
      default:
        icon = Icons.circle; color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(12),
        border: hasAlert ? Border.all(color: Colors.orange.withOpacity(0.4)) : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(children: [
          Text(type, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 8),
          Text('${ping['date']} ${ping['time']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        subtitle: hasAlert
            ? Text(alert, style: const TextStyle(color: Colors.orange, fontSize: 12))
            : (lat.isNotEmpty && lat != '0')
                ? Text('$lat, $lon', style: const TextStyle(color: Colors.white38, fontSize: 11))
                : null,
        trailing: (lat.isNotEmpty && lat != '0' && lat != '')
            ? IconButton(
                icon: const Icon(Icons.map, color: Colors.white38, size: 20),
                onPressed: () {
                  // Otworz mape - w przegladarce
                },
              )
            : null,
      ),
    );
  }
}
