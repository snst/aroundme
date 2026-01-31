import 'dart:convert';

import 'package:aroundme/places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapSearch {

  MapSearch(this.apiKey, this.onSearchFinished);

  String? apiKey;
  LatLngBounds? mapBounds;
  String lastSearchText = "";
  String nextPageToken = "";
  Places places = Places();
  Function onSearchFinished;

  void clearNextPageToken() {
    print("clearNextPageToken");
    nextPageToken = "";
  }

  void clearResults() {
    places.clear();
  }

  void setMapBounds(LatLngBounds mapBounds) {
    this.mapBounds = mapBounds;
    clearNextPageToken();
  }

  Future<void> search(String searchText, bool newSearch) async {

    if (newSearch || searchText != lastSearchText) {
      clearNextPageToken();
    }
    lastSearchText = searchText;
    if (lastSearchText.isEmpty) {
      return;
    }

    final url = Uri.parse('https://places.googleapis.com/v1/places:searchText');
    Map<String, dynamic> body = {
      "textQuery": lastSearchText, // This acts as the primaryType filter
      //      "minRating": _currentRating,
      "pageSize": 10,
      "locationRestriction": {
        "rectangle": {
          "low": {"latitude": mapBounds!.southwest.latitude, "longitude": mapBounds!.southwest.longitude},
          "high": {"latitude": mapBounds!.northeast.latitude, "longitude": mapBounds!.northeast.longitude},
        },
      },
    };

    if (nextPageToken.isNotEmpty) {
      body["pageToken"] = nextPageToken;
      print("search token: $nextPageToken");
    } else {
      print("new search");
    }

    if ((apiKey ?? "").isNotEmpty) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey!,
            // ⚠️ IMPORTANT: Field Mask defines what data is returned
            'X-Goog-FieldMask':
                'places.displayName,places.rating,places.userRatingCount,nextPageToken,places.location,places.googleMapsUri,places.googleMapsLinks,places.id,places.attributions,places.movedPlace',
          },
          body: json.encode(body),
        );
        //             'X-Goog-FieldMask': 'places.displayName,places.rating,places.userRatingCount,places.formattedAddress'
        if (response.statusCode == 200) {
          int cnt = 0;
          int cntAdded = 0;
          final data = json.decode(response.body);
          //setState(() {
            List<dynamic> newPlaces = data['places'] ?? [];
            nextPageToken = data['nextPageToken'] ?? "";

            /*

            }*/

            print("got token: ${nextPageToken}");
            for (var place in newPlaces) {
              cnt++;
              if (places.add(place))
                cntAdded++;
            }
          print("got ${cnt}, added ${cntAdded}");
          onSearchFinished(places, nextPageToken.isNotEmpty);

      //      _filter._updateFilteredPlacesAndMarkers(_places);
      //    });
        } else {
          debugPrint("Error: ${response.body}");
          throw Exception("Failed to load places");
        }
      } catch (e) {
        //setState(() => _isLoading = false);
        debugPrint(e.toString());
      }
    }
  }
}
