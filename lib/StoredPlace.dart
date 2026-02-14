import 'package:aroundme/places.dart';

class StoredPlace extends Place{
  StoredPlace({required super.id, required super.userRatingCnt, required super.rating, required super.location, required super.name, required super.gmDirections, required super.gmPlace, required super.gmReviews, required super.gmPhotos});

}

class PlaceStorage
{
  Map<String, StoredPlace> places = {};

  void add(Place place)
  {
    places[place.id] = StoredPlace(id: place.id, userRatingCnt: place.userRatingCnt, rating: place.rating, location: place.location,
    name: place.name, gmDirections: place.gmDirections, gmPlace: place.gmPlace, gmReviews: place.gmReviews, gmPhotos: place.gmPhotos);
  }

  void remove(String id)
  {
    places.remove(id);
  }

  bool contains(String id)
  {
    return places.containsKey(id);
  }

  StoredPlace get(String id)
  {
    return places[id]!;
  }


}