import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../services/work_session_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkSessionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: const Color(0xFF1B2838),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              'Wybierz pracownika:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...AppConstants.employees
              .where((e) => e['phone']!.isNotEmpty)
              .map((employee) {
            final isSelected = provider.userPhone == employee['phone'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1B3A5C)
                    : const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4FC3F7)
                      : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? const Color(0xFF4FC3F7)
                      : Colors.white12,
                  child: Text(
                    employee['name']![0],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  employee['name']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  employee['phone']!,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                        color: Color(0xFF4FC3F7))
                    : null,
                onTap: () async {
                  if (provider.isWorking || provider.isOnBreak) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Nie można zmienić pracownika w trakcie pracy!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  await provider.setEmployee(
                    employee['name']!,
                    employee['phone']!,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Wybrano: ${employee['name']}'),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  }
                },
              ),
            );
          }),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Wersja 1.0.0 • Dział Produkcja',
              style: TextStyle(color: Colors.white24, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
