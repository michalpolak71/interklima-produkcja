import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'location_service.dart';
import 'connectivity_service.dart';
import 'webhook_service.dart';

enum WorkState { idle, working, onBreak }

class WorkSessionProvider extends ChangeNotifier {
  WorkState _state = WorkState.idle;
  DateTime? _startTime;
  DateTime? _breakStartTime;
  Duration _totalBreakDuration = Duration.zero;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String? _userPhone;
  String? _userName;
  LocationStatus _locationStatus = LocationStatus.loading;
  String? _lastError;
  bool _isSending = false;

  // Getters
  WorkState get state => _state;
  Duration get elapsed => _elapsed;
  String? get userPhone => _userPhone;
  String? get userName => _userName;
  LocationStatus get locationStatus => _locationStatus;
  String? get lastError => _lastError;
  bool get isSending => _isSending;
  bool get isWorking => _state == WorkState.working;
  bool get isOnBreak => _state == WorkState.onBreak;
  bool get isIdle => _state == WorkState.idle;

  String get elapsedFormatted {
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get locationStatusText {
    switch (_locationStatus) {
      case LocationStatus.inCompany:
        return 'W firmie ✓';
      case LocationStatus.outsideCompany:
        return 'Poza firmą ⚠';
      case LocationStatus.gpsDisabled:
        return 'GPS wyłączony';
      case LocationStatus.permissionDenied:
        return 'Brak uprawnień GPS';
      case LocationStatus.loading:
        return 'Sprawdzanie...';
    }
  }

  Color get locationStatusColor {
    switch (_locationStatus) {
      case LocationStatus.inCompany:
        return Colors.green;
      case LocationStatus.outsideCompany:
        return Colors.orange;
      case LocationStatus.gpsDisabled:
      case LocationStatus.permissionDenied:
        return Colors.red;
      case LocationStatus.loading:
        return Colors.grey;
    }
  }

  WorkSessionProvider() {
    _loadSavedState();
  }

  /// Załaduj zapisany stan (przetrwanie restartu)
  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    _userPhone = prefs.getString('user_phone');
    _userName = prefs.getString('user_name');

    final stateStr = prefs.getString('work_state');
    final startTimeStr = prefs.getString('start_time');
    final breakDurationMs = prefs.getInt('break_duration_ms') ?? 0;
    final breakStartStr = prefs.getString('break_start_time');

    if (stateStr != null && startTimeStr != null) {
      _startTime = DateTime.tryParse(startTimeStr);
      _totalBreakDuration = Duration(milliseconds: breakDurationMs);

      if (stateStr == 'working' && _startTime != null) {
        _state = WorkState.working;
        _updateElapsed();
        _startTimer();
      } else if (stateStr == 'onBreak' && _startTime != null) {
        _state = WorkState.onBreak;
        if (breakStartStr != null) {
          _breakStartTime = DateTime.tryParse(breakStartStr);
        }
        _updateElapsed();
        // Nie startuj timera - jesteśmy na przerwie
      }
    }

    _checkLocation();
    notifyListeners();
  }

  /// Zapisz stan do SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userPhone != null) prefs.setString('user_phone', _userPhone!);
    if (_userName != null) prefs.setString('user_name', _userName!);

    switch (_state) {
      case WorkState.idle:
        prefs.remove('work_state');
        prefs.remove('start_time');
        prefs.remove('break_duration_ms');
        prefs.remove('break_start_time');
        break;
      case WorkState.working:
        prefs.setString('work_state', 'working');
        if (_startTime != null) {
          prefs.setString('start_time', _startTime!.toIso8601String());
        }
        prefs.setInt(
            'break_duration_ms', _totalBreakDuration.inMilliseconds);
        prefs.remove('break_start_time');
        break;
      case WorkState.onBreak:
        prefs.setString('work_state', 'onBreak');
        if (_startTime != null) {
          prefs.setString('start_time', _startTime!.toIso8601String());
        }
        prefs.setInt(
            'break_duration_ms', _totalBreakDuration.inMilliseconds);
        if (_breakStartTime != null) {
          prefs.setString(
              'break_start_time', _breakStartTime!.toIso8601String());
        }
        break;
    }
  }

  /// Ustaw dane pracownika
  Future<void> setEmployee(String name, String phone) async {
    _userName = name;
    _userPhone = phone;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_phone', phone);
    prefs.setString('user_name', name);
    notifyListeners();
  }

  /// Sprawdź lokalizację
  Future<void> _checkLocation() async {
    _locationStatus = await LocationService.checkLocationStatus();
    notifyListeners();
  }

  /// Walidacja przed START/STOP
  Future<String?> _validateRequirements() async {
    // Sprawdź internet
    bool hasNet = await ConnectivityService.hasInternet();
    if (!hasNet) {
      return 'Włącz dane komórkowe lub WiFi';
    }

    // Sprawdź GPS
    bool gpsReady = await LocationService.isGpsReady();
    if (!gpsReady) {
      return 'Włącz lokalizację (GPS)';
    }

    // Sprawdź czy pracownik wybrany
    if (_userPhone == null || _userPhone!.isEmpty) {
      return 'Wybierz pracownika w Ustawieniach';
    }

    return null; // OK
  }

  /// START PRACY
  Future<String?> startWork() async {
    final error = await _validateRequirements();
    if (error != null) return error;

    _isSending = true;
    _lastError = null;
    notifyListeners();

    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position == null) {
        _isSending = false;
        notifyListeners();
        return 'Nie udało się pobrać lokalizacji';
      }

      bool success = await WebhookService.sendAction(
        type: 'START',
        phone: _userPhone!,
        lat: position.latitude,
        lon: position.longitude,
      );

      if (!success) {
        _isSending = false;
        notifyListeners();
        return 'Błąd wysyłania danych. Sprawdź internet.';
      }

      _startTime = DateTime.now();
      _totalBreakDuration = Duration.zero;
      _state = WorkState.working;
      _elapsed = Duration.zero;
      _startTimer();
      _locationStatus = LocationService.distanceFromCompany(
                  position.latitude, position.longitude) <=
              AppConstants.alertRadiusMeters
          ? LocationStatus.inCompany
          : LocationStatus.outsideCompany;

      _isSending = false;
      await _saveState();
      notifyListeners();
      return null; // sukces
    } catch (e) {
      _isSending = false;
      _lastError = e.toString();
      notifyListeners();
      return 'Błąd: $e';
    }
  }

  /// STOP PRACY
  Future<String?> stopWork() async {
    final error = await _validateRequirements();
    if (error != null) return error;

    _isSending = true;
    notifyListeners();

    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position == null) {
        _isSending = false;
        notifyListeners();
        return 'Nie udało się pobrać lokalizacji';
      }

      bool success = await WebhookService.sendAction(
        type: 'STOP',
        phone: _userPhone!,
        lat: position.latitude,
        lon: position.longitude,
      );

      if (!success) {
        _isSending = false;
        notifyListeners();
        return 'Błąd wysyłania danych. Sprawdź internet.';
      }

      _timer?.cancel();
      _state = WorkState.idle;
      _startTime = null;
      _totalBreakDuration = Duration.zero;
      _elapsed = Duration.zero;

      _isSending = false;
      await _saveState();
      notifyListeners();
      return null;
    } catch (e) {
      _isSending = false;
      notifyListeners();
      return 'Błąd: $e';
    }
  }

  /// PRZERWA
  Future<String?> startBreak() async {
    if (_state != WorkState.working) return 'Musisz być w pracy';

    _isSending = true;
    notifyListeners();

    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position == null) {
        _isSending = false;
        notifyListeners();
        return 'Nie udało się pobrać lokalizacji';
      }

      bool success = await WebhookService.sendAction(
        type: 'PRZERWA',
        phone: _userPhone!,
        lat: position.latitude,
        lon: position.longitude,
      );

      if (!success) {
        _isSending = false;
        notifyListeners();
        return 'Błąd wysyłania danych.';
      }

      _breakStartTime = DateTime.now();
      _timer?.cancel();
      _state = WorkState.onBreak;

      _isSending = false;
      await _saveState();
      notifyListeners();
      return null;
    } catch (e) {
      _isSending = false;
      notifyListeners();
      return 'Błąd: $e';
    }
  }

  /// KONIEC PRZERWY
  Future<String?> endBreak() async {
    if (_state != WorkState.onBreak) return 'Nie jesteś na przerwie';

    _isSending = true;
    notifyListeners();

    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position == null) {
        _isSending = false;
        notifyListeners();
        return 'Nie udało się pobrać lokalizacji';
      }

      bool success = await WebhookService.sendAction(
        type: 'KONIEC_PRZERWY',
        phone: _userPhone!,
        lat: position.latitude,
        lon: position.longitude,
      );

      if (!success) {
        _isSending = false;
        notifyListeners();
        return 'Błąd wysyłania danych.';
      }

      if (_breakStartTime != null) {
        _totalBreakDuration +=
            DateTime.now().difference(_breakStartTime!);
      }
      _breakStartTime = null;
      _state = WorkState.working;
      _updateElapsed();
      _startTimer();

      _isSending = false;
      await _saveState();
      notifyListeners();
      return null;
    } catch (e) {
      _isSending = false;
      notifyListeners();
      return 'Błąd: $e';
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
      notifyListeners();
    });
  }

  void _updateElapsed() {
    if (_startTime == null) return;
    final totalTime = DateTime.now().difference(_startTime!);
    _elapsed = totalTime - _totalBreakDuration;
    if (_elapsed.isNegative) _elapsed = Duration.zero;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}


