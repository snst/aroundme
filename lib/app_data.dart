// Copyright 2026 Stefan Schmidt
import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter.dart';

class AppData
{
  ResultFilter resultFilter = ResultFilter();
  Places foundPlaces = Places();
  Places filteredPlaces = Places();
  Places favoritePlaces = Places();
  late Places lastFilteredPlacesSource = foundPlaces;

  void clear() {
    resultFilter.clear();
    filteredPlaces.clear();
  }

  void filterAndSortPlaces(SortPlaces sortby) {
    resultFilter.sortBy = sortby;
    filteredPlaces = resultFilter.filter(lastFilteredPlacesSource);
  }

  void onSearchFinished(Places places) {
    foundPlaces = places;
    lastFilteredPlacesSource = places;

    for(var place in places.places.values) {
      if(favoritePlaces.contains(place.id)) {
        place.isFavorite = true;
      }
    }

    updateFilteredSearchResults();
  }

  void onShowFavorites(Places places) {
    lastFilteredPlacesSource = places;
    updateFilteredSearchResults();
  }

  /*
  void setAndShowFavorites(Places places) {
    foundPlaces.copyFrom(places);
    updateFilteredSearchResults();
  }*/

  void updateFilteredSearchResults() {
    filteredPlaces = resultFilter.filter(lastFilteredPlacesSource);
  }

  void resultFilterCnt() => resultFilter.cntVisible(lastFilteredPlacesSource);

  double resultFilterGetSliderValueRating() => resultFilter.adjustedRating(lastFilteredPlacesSource.minRating, lastFilteredPlacesSource.maxRating);
  double resultFilterGetSliderValueMinRating() => lastFilteredPlacesSource.minRating;
  double resultFilterGetSliderValueMaxRating() => lastFilteredPlacesSource.maxRating;
  void resultFilterSetRating(double value) {
    resultFilter.rating = value;
    resultFilterCnt();
  }

  double resultFilterGetSliderValueRatingCnt() => resultFilter.adjustedRatingCnt(foundPlaces.minUserRatingCnt, foundPlaces.maxUserRatingCnt).toDouble();
  double resultFilterGetSliderValueMinRatingCnt() => foundPlaces.minUserRatingCnt.toDouble();
  double resultFilterGetSliderValueMaxRatingCnt() => foundPlaces.maxUserRatingCnt.toDouble();
  void resultFilterSetRatingCnt(double value) {
    resultFilter.ratingCnt = value.toInt();
    resultFilterCnt();
  }

  void resultFilterClearMinValues() {
    resultFilter.rating = foundPlaces.minRating;
    resultFilter.ratingCnt = foundPlaces.minUserRatingCnt;
    resultFilter.cntVisible(foundPlaces);
  }
}