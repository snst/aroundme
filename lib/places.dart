// Copyright 2026 Stefan Schmidt
import 'dart:convert';

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
    required this.category,
  });

  factory Place.fromJson(Map<String, dynamic> json, String category) {
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
      category: category,
    );
  }

  // Converts the Object into a Map
  Map<String, dynamic> toJsonFile() {
    return {
      'id': id,
      'ratingCnt': userRatingCnt,
      'rating': rating,
      'lat': location.latitude,
      'lon': location.longitude,
      'name': name,
      'gmPlace': gmPlace,
      'category': category,
    };
  }

  factory Place.fromJsonFile(Map<String, dynamic> json) {
    Place place = Place(
      id: json['id'] ?? '',
      userRatingCnt: (json['ratingCnt'] ?? 0).toInt(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      location: LatLng(json['lat'] ?? 0.0, json['lon'] ?? 0.0),
      name: json['name'] ?? '',
      gmDirections: '',
      gmPlace: json['gmPlace'] ?? '',
      gmReviews: '',
      gmPhotos: '',
      category: json['category'] ?? '',
    );
    place.isFavorite = true;
    return place;
  }


  bool containsText(String text)
  {
    return name.toLowerCase().contains(text.toLowerCase()) || category.toLowerCase().contains(text.toLowerCase());
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
  late String category;
  bool isFavorite = false;
}

class Places {
  Map<String, Place> places = {};
  List<Place> items = [];

  //List<String> placesIds = [];
  int minUserRatingCnt = 0;
  int maxUserRatingCnt = 0;
  double minRating = 0;
  double maxRating = 0;

  bool isEmpty() {
    return places.isEmpty;
  }

  void copyFrom(Places other) {
    items = List<Place>.from(other.items);
    places = Map<String, Place>.from(other.places);
    minUserRatingCnt = other.minUserRatingCnt;
    maxUserRatingCnt = other.maxUserRatingCnt;
    minRating = other.minRating;
    maxRating = other.maxRating;
  }

  double normRatingCnt(int val) {
    if (maxUserRatingCnt == minUserRatingCnt) {
      return 1.0;
    }
    return (val - minUserRatingCnt) / (maxUserRatingCnt - minUserRatingCnt);
  }

  bool add(Place place) {
    if (places.containsKey(place.id)) {
      items.remove(place);
    }
    places[place.id] = place;
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

  void clear() {
    places.clear();
    items.clear();
    minUserRatingCnt = 0;
    maxUserRatingCnt = 0;
    minRating = 0;
    maxRating = 0;
  }

  bool contains(String id) {
    return places.containsKey(id);
  }

  Place? get(String id) {
    return places[id];
  }

  void remove(String id) {
    Place? place = get(id);
    if (place != null) {
      places.remove(id);
      items.remove(place);
    }
  }

  String toJson() {
    List<Map<String, dynamic>> jsonList = places.values.map((place) => place.toJsonFile()).toList();
    String jsonString = jsonEncode(jsonList);
    return jsonString;
  }


  void fromJson(String jsonString) {
    clear();
    List<dynamic> dynamicList = jsonDecode(jsonString);
    for (var jsonItem in dynamicList) {
      Place place = Place.fromJsonFile(jsonItem);
      add(place);
    }
  }

  Places filterByText(String searchText) {
    Places ret = Places();
    searchText = searchText.toLowerCase();

    for (final place in places.values) {
      if (place.containsText(searchText))
        ret.add(place);
    }
    return ret;
  }
}
