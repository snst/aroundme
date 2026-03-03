// Copyright 2026 Stefan Schmidt
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchMode {
  search,
  favorite,
  both
}

IconData placeSelectionToIcon(SearchMode placeSelection) {
  switch (placeSelection) {
    case SearchMode.search:
      return Icons.search;
    case SearchMode.favorite:
      return Icons.favorite_border_sharp;
    case SearchMode.both:
      return Icons.send_and_archive_outlined;
  }
}

SearchMode nextSearchMode(SearchMode placeSelection) {
  switch (placeSelection) {
    case SearchMode.search:
      return SearchMode.favorite;
    case SearchMode.favorite:
      return SearchMode.search;
    case SearchMode.both:
      return SearchMode.search;
  }
}



class Settings {
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key') ?? "";
  }

  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', key);
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

  static Future<String> getFavoriteFile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('favorite_file') ?? "";
  }

  static Future<void> setFavoriteFile(String fullPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_file', fullPath);
  }

}
