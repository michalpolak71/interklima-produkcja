import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/work_session_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WorkSessionProvider>(context, listen: false);
    if (provider.userPhone != null && provider.userPhone!.isNotEmpty) {
      _phoneController.text = provider.userPhone!;
      _isSaved = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpisz numer telefonu'), backgroundColor: Colors.red));
      return;
    }
    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numer musi mie\u0107 minimum 9 cyfr'), backgroundColor: Colors.red));
      return;
    }

    final provider = Provider.of<WorkSessionProvider>(context, listen: false);
    if (provider.isWorking || provider.isOnBreak) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie mo\u017cna zmieni\u0107 numeru w trakcie pracy!'), backgroundColor: Colors.red));
      return;
    }

    await provider.setEmployee(phone, phone);
    setState(() => _isSaved = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Numer zapisany: $phone'), backgroundColor: Colors.green.shade700));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia'), backgroundColor: const Color(0xFF1B2838)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tw\u00f3j numer telefonu:',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Wpisz sw\u00f3j numer \u2014 s\u0142u\u017cy jako identyfikator w systemie.',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
              decoration: InputDecoration(
                hintText: 'np. 608651538',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.phone, color: Colors.white38),
                filled: true, fillColor: const Color(0xFF1B2838),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4FC3F7))),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(_isSaved ? Icons.check : Icons.save),
                label: Text(_isSaved ? 'ZAPISANO \u2713' : 'ZAPAMI\u0118TAJ',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved ? Colors.green.shade700 : const Color(0xFF1B3A5C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
            if (_isSaved) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.3))),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('Numer zapami\u0119tany. Mo\u017cesz startowa\u0107 prac\u0119.',
                      style: TextStyle(color: Colors.green, fontSize: 13))),
                ]),
              ),
            ],
            const Spacer(),
            const Center(child: Text('Wersja 1.3.0 \u2022 Dzia\u0142 Produkcja',
                style: TextStyle(color: Colors.white24, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}
