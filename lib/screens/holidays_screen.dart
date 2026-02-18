import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dni wolne 2026'),
        backgroundColor: const Color(0xFF1B2838),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.holidays2026.length,
        itemBuilder: (context, index) {
          final holiday = AppConstants.holidays2026[index];
          final date = DateTime.parse(holiday['date']!);
          final isPast = date.isBefore(now);
          final isToday = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(now);

          final dayName = _polishDayName(date.weekday);
          final dateFormatted = DateFormat('d MMMM', 'pl').format(date);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFF1B3A5C)
                  : const Color(0xFF1B2838),
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
                  : null,
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPast
                      ? Colors.white.withOpacity(0.05)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isPast ? Colors.white24 : Colors.red.shade300,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                holiday['name']!,
                style: TextStyle(
                  color: isPast ? Colors.white38 : Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: isPast ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '$dayName, ${_polishMonth(date.month)} ${date.day}',
                style: TextStyle(
                  color: isPast ? Colors.white24 : Colors.white54,
                  fontSize: 13,
                ),
              ),
              trailing: isPast
                  ? const Icon(Icons.check, color: Colors.white24, size: 18)
                  : isToday
                      ? const Text('DZIŚ',
                          style: TextStyle(
                            color: Color(0xFF4FC3F7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ))
                      : null,
            ),
          );
        },
      ),
    );
  }

  String _polishDayName(int weekday) {
    const days = [
      'Poniedziałek',
      'Wtorek',
      'Środa',
      'Czwartek',
      'Piątek',
      'Sobota',
      'Niedziela',
    ];
    return days[weekday - 1];
  }

  String _polishMonth(int month) {
    const months = [
      'stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca',
      'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia',
    ];
    return months[month - 1];
  }
}
