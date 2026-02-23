import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  List<Map<String, String>> _requests = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() { _loading = true; _error = null; });
    try {
      final url = '${AppConstants.webhookUrl}?action=LIST_URLOPY';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && response.body.contains('"requests"')) {
        final data = jsonDecode(response.body);
        final list = data['requests'] as List<dynamic>;
        _requests = list.map((r) => Map<String, String>.from(
          (r as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
        )).toList();
      } else {
        _error = 'Nie uda\u0142o si\u0119 pobra\u0107 wniosk\u00f3w';
      }
    } catch (e) {
      _error = 'B\u0142\u0105d po\u0142\u0105czenia: $e';
    }
    setState(() { _loading = false; });
  }

  Future<void> _updateStatus(int row, String newStatus) async {
    try {
      final url = '${AppConstants.webhookUrl}?action=UPDATE_URLOP&row=$row&status=$newStatus';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status zmieniony na: $newStatus'),
            backgroundColor: newStatus == 'ZATWIERDZONY' ? Colors.green.shade700 : Colors.red.shade700,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('B\u0142\u0105d: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zatwierdzanie urlop\u00f3w'),
        backgroundColor: const Color(0xFF1B2838),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : _error != null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadRequests, child: const Text('Spr\u00f3buj ponownie')),
                  ]))
              : _requests.isEmpty
                  ? const Center(child: Text('Brak wniosk\u00f3w urlopowych',
                      style: TextStyle(color: Colors.white54, fontSize: 16)))
                  : RefreshIndicator(
                      onRefresh: _loadRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        itemBuilder: (ctx, i) => _buildRequestCard(_requests[i]),
                      ),
                    ),
    );
  }

  Widget _buildRequestCard(Map<String, String> req) {
    final status = (req['status'] ?? 'NOWY').toUpperCase();
    final isNew = status == 'NOWY';
    final isApproved = status == 'ZATWIERDZONY' || status == 'ZATWIERDZONE';
    final isRejected = status == 'ODRZUCONY' || status == 'ODRZUCONE';

    Color statusColor = Colors.orange;
    if (isApproved) statusColor = Colors.green;
    if (isRejected) statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isNew ? Colors.orange.withOpacity(0.4) : Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(req['pracownik'] ?? 'Nieznany',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.category, req['typ'] ?? ''),
            _infoRow(Icons.date_range, '${req['od'] ?? ''} - ${req['do'] ?? ''}'),
            if (req['dni'] != null && req['dni']!.isNotEmpty)
              _infoRow(Icons.timelapse, '${req['dni']} dni'),
            if (req['uwagi'] != null && req['uwagi']!.isNotEmpty)
              _infoRow(Icons.note, req['uwagi']!),
            _infoRow(Icons.calendar_today, 'Wniosek z: ${req['data'] ?? ''}'),
            if (isNew) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(int.tryParse(req['row'] ?? '0') ?? 0, 'ZATWIERDZONY'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('ZATWIERD\u0179'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(int.tryParse(req['row'] ?? '0') ?? 0, 'ODRZUCONY'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('ODRZU\u0106'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}
