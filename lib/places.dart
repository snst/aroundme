// Copyright 2026 Stefan Schmidt
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // You'll need this package


// Helper to launch URLs
Future<void> launchURL(String url) async {
  if (url.isEmpty) return;
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}


class Place {
  Place({
    required this.id,
    required this.userRatingCnt,
    required this.rating,
    required this.location,
    required this.name,
    required this.gmDirections,
    required this.gmPlace,
    required this.gmReviews,
    required this.gmPhotos,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? '',
      userRatingCnt: (json['userRatingCount'] ?? 0).toInt(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      location: LatLng(json['location']?['latitude'] ?? 0.0, json['location']?['longitude'] ?? 0.0),
      name: json['displayName']?['text'] ?? 'Unknown Name',
      gmDirections: json['googleMapsLinks']?['directionsUri'] ?? '',
      gmPlace: json['googleMapsLinks']?['placeUri'] ?? '',
      gmReviews: json['googleMapsLinks']?['reviewsUri'] ?? '',
      gmPhotos: json['googleMapsLinks']?['photosUri'] ?? '',
    );
  }

  late String id;
  late int userRatingCnt;
  late double rating;
  late LatLng location;
  late String name;

  //late String gm;
  late String gmDirections;
  late String gmPlace;
  late String gmReviews;
  late String gmPhotos;
  bool isFavorite = false;
}

class Places {
  List<Place> items = [];
  List<String> placesIds = [];
  int minUserRatingCnt = 0;
  int maxUserRatingCnt = 0;
  double minRating = 0;
  double maxRating = 0;

  double normRatingCnt(int val) {
    if (maxUserRatingCnt == minUserRatingCnt) {
      return 1.0;
    }
    return (val - minUserRatingCnt) / (maxUserRatingCnt - minUserRatingCnt);
  }

  bool add(Place place) {
    if (!placesIds.contains(place.id)) {
      placesIds.add(place.id);
      items.add(place);
      if (place.userRatingCnt > maxUserRatingCnt) {
        maxUserRatingCnt = place.userRatingCnt;
      }
      //if (minUserRatingCnt == 0 || place.userRatingCnt < minUserRatingCnt) {
      //  minUserRatingCnt = place.userRatingCnt;
      //}
      if (place.rating > maxRating) {
        maxRating = place.rating;
      }
      //if (minRating == 0 || place.rating < minRating) {
      //  minRating = place.rating;
      //}
      return true;
    }
    return false;
  }

  void clear() {
    items.clear();
    placesIds.clear();
    minUserRatingCnt = 0;
    maxUserRatingCnt = 0;
    minRating = 0;
    maxRating = 0;
  }
}
