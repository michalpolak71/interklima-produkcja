import 'package:geolocator/geolocator.dart';
import '../constants.dart';

enum LocationStatus {
  inCompany,
  outsideCompany,
  gpsDisabled,
  permissionDenied,
  loading,
}

class LocationService {
  /// Sprawdź czy GPS jest włączony i mamy uprawnienia
  static Future<bool> isGpsReady() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Pobierz aktualną pozycję
  static Future<Position?> getCurrentPosition() async {
    try {
      if (!await isGpsReady()) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// Sprawdź status lokalizacji względem firmy
  static Future<LocationStatus> checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationStatus.gpsDisabled;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationStatus.permissionDenied;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.permissionDenied;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        AppConstants.companyLat,
        AppConstants.companyLon,
      );

      return distance <= AppConstants.alertRadiusMeters
          ? LocationStatus.inCompany
          : LocationStatus.outsideCompany;
    } catch (e) {
      return LocationStatus.gpsDisabled;
    }
  }

  /// Oblicz odległość od firmy
  static double distanceFromCompany(double lat, double lon) {
    return Geolocator.distanceBetween(
      lat,
      lon,
      AppConstants.companyLat,
      AppConstants.companyLon,
    );
  }
}
