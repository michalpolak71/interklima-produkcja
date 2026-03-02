import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/work_session_provider.dart';
import '../services/webhook_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _leaveType = 'Urlop wypoczynkowy';
  final TextEditingController _noteController = TextEditingController();
  bool _isSending = false;

  final List<String> _leaveTypes = [
    'Urlop wypoczynkowy',
    'Urlop na żądanie',
    'Urlop okolicznościowy',
    'Zwolnienie lekarskie',
    'Dzień wolny (odbiór)',
    'Inny',
  ];

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4FC3F7),
              surface: Color(0xFF1B2838),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  int get _dayCount {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _submit() async {
    final provider =
        Provider.of<WorkSessionProvider>(context, listen: false);

    if (provider.userPhone == null || provider.userPhone!.isEmpty) {
      _showMessage('Najpierw wybierz pracownika w Ustawieniach', isError: true);
      return;
    }
    if (_startDate == null || _endDate == null) {
      _showMessage('Wybierz daty urlopu', isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      // Wysyłamy wniosek jako specjalny typ na webhook
      // Skrypt Apps Script może to obsłużyć później
      final now = DateTime.now();
      final payload = {
        'date': DateFormat('dd.MM.yyyy').format(now),
        'time': DateFormat('HH:mm').format(now),
        'phone': provider.userPhone!,
        'type': 'URLOP',
        'lat': '0',
        'lon': '0',
        'urlop_od': DateFormat('dd.MM.yyyy').format(_startDate!),
        'urlop_do': DateFormat('dd.MM.yyyy').format(_endDate!),
        'urlop_typ': _leaveType,
        'urlop_uwagi': _noteController.text,
        'urlop_dni': _dayCount.toString(),
      };

      // Na razie wysyłamy prosty webhook - typ URLOP
      // Skrypt po stronie Google może to rozbudować
      bool success = await WebhookService.sendAction(
        type: 'URLOP',
        phone: provider.userPhone!,
        lat: 0,
        lon: 0,
        extraFields: {
          'urlop_od': DateFormat('dd.MM.yyyy').format(_startDate!),
          'urlop_do': DateFormat('dd.MM.yyyy').format(_endDate!),
          'urlop_typ': _leaveType,
          'urlop_uwagi': _noteController.text,
          'urlop_dni': _dayCount.toString(),
        },
      );

      setState(() => _isSending = false);

      if (success) {
        _showMessage('Wniosek urlopowy wysłany ✓');
        if (mounted) Navigator.pop(context);
      } else {
        _showMessage('Błąd wysyłania wniosku', isError: true);
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showMessage('Błąd: $e', isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wniosek urlopowy'),
        backgroundColor: const Color(0xFF1B2838),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typ urlopu
            const Text('Rodzaj:',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButton<String>(
                value: _leaveType,
                isExpanded: true,
                dropdownColor: const Color(0xFF1B2838),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                underline: const SizedBox(),
                items: _leaveTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => _leaveType = val!),
              ),
            ),
            const SizedBox(height: 24),

            // Daty
            Row(
              children: [
                Expanded(
                  child: _dateButton(
                    label: 'Od:',
                    date: _startDate,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateButton(
                    label: 'Do:',
                    date: _endDate,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),

            if (_dayCount > 0) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Liczba dni: $_dayCount',
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Uwagi
            const Text('Uwagi (opcjonalnie):',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Dodatkowe informacje...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1B2838),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF4FC3F7)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Przycisk wyślij
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _submit,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSending ? 'Wysyłanie...' : 'WYŚLIJ WNIOSEK',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A5C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateButton({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white54, size: 18),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd.MM.yyyy').format(date)
                      : 'Wybierz datę',
                  style: TextStyle(
                    color: date != null ? Colors.white : Colors.white38,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
