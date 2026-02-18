class AppConstants {
  // Webhook
  static const String webhookUrl =
      'https://script.google.com/macros/s/AKfycbw_1NLFIFbJxxS7Pco1V3ZfD5zihnqAUJDTM-p-les9yX5FzymXOTB-Fxid0c4vrf-18Q/exec';

  // Lokalizacja firmy
  static const double companyLat = 52.236189;
  static const double companyLon = 20.839213;
  static const double alertRadiusMeters = 300.0;

  // Pracownicy bez alertu GPS (telefony)
  static const List<String> noGpsAlertPhones = [
    '608651538', // Bartłomiej Drabicki
    '795561356', // Michał Polak
    '690205199', // Judyta Drabicka
  ];
}
