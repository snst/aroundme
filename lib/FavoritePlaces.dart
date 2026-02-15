import 'dart:convert';

import 'package:aroundme/places.dart';


class FavoritePlaces
{
  Map<String, Place> places = {};

  void add(Place place)
  {
    places[place.id] = place;
  }

  void remove(String id)
  {
    places.remove(id);
  }

  bool contains(String id)
  {
    return places.containsKey(id);
  }

  Place get(String id)
  {
    return places[id]!;
  }

  String getSerializedPlaces() {
    List<Map<String, dynamic>> jsonList = places.values.map((place) => place.toJsonFile()).toList();
    String jsonString = jsonEncode(jsonList);
    return jsonString;
  }

  void clear()
  {
    places.clear();
  }

  void loadData(String jsonString) {
    // 1. Decode the string into a List of dynamic objects
    List<dynamic> dynamicList = jsonDecode(jsonString);

    // 2. Map the dynamic list into a List of Place objects
    List<Place> placeList = dynamicList
        .map((jsonItem) => Place.fromJsonFile(jsonItem))
        .toList();

    // 3. (Optional) Convert back to Map<String, Place> using the ID as the key

      for (var place in placeList) {
        add(place);
      }
  }

}