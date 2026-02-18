class AppConstants {
  // Webhook
  static const String webhookUrl =
      'https://script.google.com/macros/s/AKfycbw_1NLFIFbJxxS7Pco1V3ZfD5zihnqAUJDTM-p-les9yX5FzymXOTB-Fxid0c4vrf-18Q/exec';

  // Lokalizacja firmy
  static const double companyLat = 52.236189;
  static const double companyLon = 20.839213;
  static const double alertRadiusMeters = 300.0;

  // Pracownicy bez alertu GPS
  static const List<String> noGpsAlertPhones = [
    '608651538', // Bartłomiej Drabicki
    '795561356', // Michał Polak
    '690205199', // Judyta Drabicka
  ];

  // Lista pracowników produkcji
  static const List<Map<String, String>> employees = [
    {'name': 'Bartłomiej Drabicki', 'phone': '608651538'},
    {'name': 'Krzysztof Paduch', 'phone': '791880277'},
    {'name': 'Adam Pogroszewski', 'phone': '690924700'},
    {'name': 'Michał Polak', 'phone': '795561356'},
    {'name': 'Judyta Drabicka', 'phone': '690205199'},
    {'name': 'Natalia Kossakowska', 'phone': '731809236'},
    {'name': 'Aleksandra Dmoch', 'phone': '791880566'},
    {'name': 'Magda Gołębiowska', 'phone': '884783170'},
    {'name': 'Paweł Nienałtowski', 'phone': '574370000'},
    {'name': 'Kacper Gołdyn', 'phone': '502087817'},
    {'name': 'Patryk Włodarczyk', 'phone': '537210373'},
    {'name': 'Marcin Włodarczyk', 'phone': ''},
  ];

  // Święta polskie 2026
  static const List<Map<String, String>> holidays2026 = [
    {'date': '2026-01-01', 'name': 'Nowy Rok'},
    {'date': '2026-01-06', 'name': 'Trzech Króli'},
    {'date': '2026-04-05', 'name': 'Wielkanoc'},
    {'date': '2026-04-06', 'name': 'Poniedziałek Wielkanocny'},
    {'date': '2026-05-01', 'name': 'Święto Pracy'},
    {'date': '2026-05-03', 'name': 'Święto Konstytucji 3 Maja'},
    {'date': '2026-05-14', 'name': 'Zielone Świątki'},
    {'date': '2026-06-04', 'name': 'Boże Ciało'},
    {'date': '2026-08-15', 'name': 'Wniebowzięcie NMP'},
    {'date': '2026-11-01', 'name': 'Wszystkich Świętych'},
    {'date': '2026-11-11', 'name': 'Święto Niepodległości'},
    {'date': '2026-12-25', 'name': 'Boże Narodzenie'},
    {'date': '2026-12-26', 'name': 'Drugi dzień Bożego Narodzenia'},
  ];
}
