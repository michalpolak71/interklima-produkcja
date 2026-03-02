import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants.dart';

class WebhookService {
  /// Wyślij akcję na webhook
  /// type: START, STOP, PRZERWA, KONIEC_PRZERWY
  static Future<bool> sendAction({
    required String type,
    required String phone,
    required double lat,
    required double lon,
    Map<String, String>? extraFields,
  }) async {
    final now = DateTime.now();
    final dateStr = DateFormat('dd.MM.yyyy').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    final payload = {
      'date': dateStr,
      'time': timeStr,
      'phone': phone,
      'type': type,
      'lat': lat.toStringAsFixed(6),
      'lon': lon.toStringAsFixed(6),
      if (extraFields != null) ...extraFields,
    };

    try {
      final response = await http.post(
        Uri.parse(AppConstants.webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // Google Apps Script redirectuje (302) przy sukcesie
      // http.post z dart:http podąża za przekierowaniami automatycznie
      if (response.statusCode == 200 || response.statusCode == 302) {
        return true;
      }

      // Spróbuj GET jako fallback (niektóre wersje Apps Script)
      final getResponse = await http.get(
        Uri.parse(
          '${AppConstants.webhookUrl}?${Uri(queryParameters: payload).query}',
        ),
      );
      return getResponse.statusCode == 200 || getResponse.statusCode == 302;
    } catch (e) {
      print('Webhook error: $e');
      return false;
    }
  }
}
