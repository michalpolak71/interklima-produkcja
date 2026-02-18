# INTERKLIMA - Aplikacja Produkcja

Aplikacja ewidencji czasu pracy dla działu Produkcja firmy Interklima.

## Funkcje
- **START / STOP PRACY** - rejestracja czasu z GPS i wysyłka na webhook
- **PRZERWA / KONIEC PRZERWY** - wstrzymanie licznika
- **Biegnący licznik** czasu pracy
- **Wymuszanie GPS i internetu** przed start/stop
- **Wniosek urlopowy** - formularz z wysyłką
- **Dni wolne 2026** - lista polskich świąt

## Jak uruchomić

### 1. Utwórz projekt Flutter
```bash
flutter create interklima_produkcja
cd interklima_produkcja
```

### 2. Zastąp pliki
Skopiuj zawartość tego repo do utworzonego projektu:
- Zastąp `pubspec.yaml`
- Zastąp cały folder `lib/`
- Skopiuj `assets/` do głównego folderu projektu

### 3. Uprawnienia Android
Edytuj `android/app/src/main/AndroidManifest.xml` - dodaj w tagu `<manifest>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Ustaw `minSdkVersion 21` w `android/app/build.gradle`.

### 4. Uprawnienia iOS
Edytuj `ios/Runner/Info.plist` - dodaj:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikacja wymaga lokalizacji do rejestracji czasu pracy.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Aplikacja wymaga lokalizacji do rejestracji czasu pracy.</string>
```

### 5. Instalacja zależności
```bash
flutter pub get
```

### 6. Wygeneruj ikonę
```bash
dart run flutter_launcher_icons
```

### 7. Uruchom
```bash
flutter run
```

### 8. Zbuduj APK
```bash
flutter build apk --release
```
APK znajdziesz w `build/app/outputs/flutter-apk/app-release.apk`

## Webhook
Dane wysyłane na: Apps Script INTERKLIMA_EWIDENCJA
Format:
```json
{
  "date": "18.02.2026",
  "time": "07:00",
  "phone": "608651538",
  "type": "START",
  "lat": "52.236189",
  "lon": "20.839213"
}
```

## Struktura
```
lib/
├── main.dart                    # Entry point
├── constants.dart               # Webhook URL, GPS, pracownicy, święta
├── screens/
│   ├── home_screen.dart         # Główna strona - START/STOP/PRZERWA
│   ├── settings_screen.dart     # Wybór pracownika
│   ├── holidays_screen.dart     # Dni wolne 2026
│   └── leave_request_screen.dart # Wniosek urlopowy
└── services/
    ├── work_session_provider.dart # State management (Provider)
    ├── location_service.dart      # GPS
    ├── webhook_service.dart       # Wysyłka danych
    └── connectivity_service.dart  # Sprawdzanie internetu
```

## GitHub
```bash
git init
git add .
git commit -m "Initial: INTERKLIMA Produkcja v1.0"
git remote add origin https://github.com/michalpolak71/interklima-produkcja.git
git push -u origin main
```
