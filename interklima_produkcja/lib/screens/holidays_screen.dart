import 'package:flutter/material.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  static const List<Map<String, String>> holidays = [
    {'date': '2026-01-01', 'day': '1', 'month': 'Styczeń', 'weekday': 'Czwartek', 'name': 'Nowy Rok'},
    {'date': '2026-01-06', 'day': '6', 'month': 'Styczeń', 'weekday': 'Wtorek', 'name': 'Trzech Króli'},
    {'date': '2026-04-05', 'day': '5', 'month': 'Kwiecień', 'weekday': 'Niedziela', 'name': 'Wielkanoc'},
    {'date': '2026-04-06', 'day': '6', 'month': 'Kwiecień', 'weekday': 'Poniedziałek', 'name': 'Poniedziałek Wielkanocny'},
    {'date': '2026-05-01', 'day': '1', 'month': 'Maj', 'weekday': 'Piątek', 'name': 'Święto Pracy'},
    {'date': '2026-05-03', 'day': '3', 'month': 'Maj', 'weekday': 'Niedziela', 'name': 'Święto Konstytucji 3 Maja'},
    {'date': '2026-05-14', 'day': '14', 'month': 'Maj', 'weekday': 'Czwartek', 'name': 'Zielone Świątki'},
    {'date': '2026-06-04', 'day': '4', 'month': 'Czerwiec', 'weekday': 'Czwartek', 'name': 'Boże Ciało'},
    {'date': '2026-08-15', 'day': '15', 'month': 'Sierpień', 'weekday': 'Sobota', 'name': 'Wniebowzięcie NMP'},
    {'date': '2026-11-01', 'day': '1', 'month': 'Listopad', 'weekday': 'Niedziela', 'name': 'Wszystkich Świętych'},
    {'date': '2026-11-11', 'day': '11', 'month': 'Listopad', 'weekday': 'Środa', 'name': 'Święto Niepodległości'},
    {'date': '2026-12-25', 'day': '25', 'month': 'Grudzień', 'weekday': 'Piątek', 'name': 'Boże Narodzenie'},
    {'date': '2026-12-26', 'day': '26', 'month': 'Grudzień', 'weekday': 'Sobota', 'name': 'Drugi dzień Bożego Narodzenia'},
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dni wolne 2026'),
        backgroundColor: const Color(0xFF1B2838),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: holidays.length,
        itemBuilder: (context, index) {
          final holiday = holidays[index];
          final isPast = holiday['date']!.compareTo(todayStr) < 0;
          final isToday = holiday['date'] == todayStr;

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
                    holiday['day']!,
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
                '${holiday['weekday']}, ${holiday['day']} ${holiday['month']}',
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
}
