// Copyright 2026 Stefan Schmidt
import 'dart:convert';
import 'dart:math' as math;

import 'package:aroundme/places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

enum SearchType { none, text, nearby }

class MapSearch {
  MapSearch(this.apiKey, this.onSearchFinished);

  String? apiKey;
  LatLng? mapCenter;
  LatLngBounds? mapBounds;
  String lastSearchText = "";
  List<String> lastSearchNearby = [];
  String nextPageToken = "";
  Places places = Places();
  Function onSearchFinished;
  SearchType lastSearchType = SearchType.none;

  void clearNextPageToken() {
    nextPageToken = "";
  }

  void clearResults() {
    places.clear();
  }

  void setMapBounds(LatLng mapCenter, LatLngBounds mapBounds) {
    this.mapCenter = mapCenter;
    this.mapBounds = mapBounds;
    clearNextPageToken();
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  double calcRadius(LatLng mapCenter, LatLngBounds bounds) {
    const double earthRadius = 6371000; // In meters

    double dLat = _toRadians(bounds.northeast.latitude - mapCenter.latitude);
    double dLon = _toRadians(bounds.northeast.longitude - mapCenter.longitude);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(mapCenter.latitude)) *
            math.cos(_toRadians(bounds.northeast.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double radius = earthRadius * c;

    return radius;
  }

  Future<void> doSearchRequest(Uri uri, String mask, Map<String, dynamic> body) async {
    if (nextPageToken.isNotEmpty) {
      body["pageToken"] = nextPageToken;
    }
    //print("search token: $nextPageToken");
    //print(body);

    if ((apiKey ?? "").isNotEmpty) {
      try {
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json', 'X-Goog-Api-Key': apiKey!, 'X-Goog-FieldMask': mask},
          body: json.encode(body),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> newPlaces = data['places'] ?? [];
          nextPageToken = data['nextPageToken'] ?? "";

          //print("got token: ${nextPageToken}");
          for (var place in newPlaces) {
            places.add(Place.fromJson((place)));
          }
          onSearchFinished(places, nextPageToken.isNotEmpty);
        } else {
          debugPrint("Error: ${response.body}");
          throw Exception("Failed to load places");
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void searchNext() {
    if (lastSearchType == SearchType.text) {
      searchText(lastSearchText);
    } else if (lastSearchType == SearchType.nearby) {
      searchNearby(lastSearchNearby);
    }
  }

  void searchText(String searchText) {
    if (lastSearchType != SearchType.text || searchText != lastSearchText) {
      clearNextPageToken();
    }
    lastSearchText = searchText;
    lastSearchType = SearchType.text;
    if (lastSearchText.isEmpty) {
      return;
    }

    final Uri uri = Uri.parse('https://places.googleapis.com/v1/places:searchText');
    final String mask =
        'places.displayName,places.rating,places.userRatingCount,nextPageToken,places.location,places.googleMapsUri,places.googleMapsLinks,places.id,places.attributions,places.movedPlace';
    final Map<String, dynamic> body = {
      //"minRating": _currentRating,
      "textQuery": searchText, //      "pageSize": 5,
      "locationRestriction": {
        "rectangle": {
          "low": {"latitude": mapBounds!.southwest.latitude, "longitude": mapBounds!.southwest.longitude},
          "high": {"latitude": mapBounds!.northeast.latitude, "longitude": mapBounds!.northeast.longitude},
        },
      },
    };
    doSearchRequest(uri, mask, body);
  }

  void searchNearby(List<String> searchNearby) {
    if (lastSearchType != SearchType.nearby || searchNearby != lastSearchNearby) {
      clearNextPageToken();
    }
    lastSearchType = SearchType.nearby;
    lastSearchNearby = searchNearby;

    final double radius = calcRadius(mapCenter!, mapBounds!);
    final Uri uri = Uri.parse('https://places.googleapis.com/v1/places:searchNearby');
    final String mask =
        'places.displayName,places.id,places.rating,places.userRatingCount,places.location,places.googleMapsLinks';
    final Map<String, dynamic> body = {
      "includedTypes": [searchNearby], //      "maxResultCount": 5,
      "locationRestriction": {
        "circle": {
          "center": {"latitude": mapCenter!.latitude, "longitude": mapCenter!.longitude},
          "radius": radius,
        },
      },
    };
    doSearchRequest(uri, mask, body);
  }
}
