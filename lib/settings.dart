// Copyright 2026 Stefan Schmidt
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key') ?? "";
  }

  static Future<LatLng> getInitialPos() async {
    final prefs = await SharedPreferences.getInstance();
    double lat = prefs.getDouble('map_lat') ?? 49.4790322;
    double lng = prefs.getDouble('map_lng') ?? 11.1208134;
    return LatLng(lat, lng);
  }

  static Future<void> setInitialPos(LatLng pos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('map_lat', pos.latitude);
    await prefs.setDouble('map_lng', pos.longitude);
  }
}
