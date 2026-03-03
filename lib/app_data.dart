// Copyright 2026 Stefan Schmidt
import 'dart:io';

import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter.dart';
import 'package:aroundme/settings.dart';

class AppData
{
  ResultFilter resultFilter = ResultFilter();
  Places foundPlaces = Places();
  Places favoritePlaces = Places();
  Places filteredPlaces = Places();
  Function onUpdateMarkers = (Places places) {};

  late Places placesToShow = foundPlaces;
  SearchMode searchMode = SearchMode.search;


  void setSearchMode(SearchMode searchMode) {
    this.searchMode = searchMode;
    if (searchMode == SearchMode.favorite) {
      loadFavorites(null);
    }
    else if (searchMode == SearchMode.search) {
      showLastSearchResults();
    }
  }

  void loadFavorites(String? fullPath) async {
    if (fullPath != null) {
      favoritePlaces.clear();
      Settings.setFavoriteFile(fullPath);
    }

    if (favoritePlaces.isEmpty()) {
      String fullPath = await Settings.getFavoriteFile();
      File file = File(fullPath);
      String jsonString = await file.readAsString();
      favoritePlaces.fromJson(jsonString);
    }
    favoritePlaces.updateMinMaxValues();
    placesToShow = favoritePlaces;
    filterAndShowResults();
  }

  void saveFavoritesAs(String fullPath) async {
    String jsonString = favoritePlaces.toJson();
    File(fullPath).writeAsStringSync(jsonString);
  }

  void showLastSearchResults() {
    placesToShow = foundPlaces;
    filterAndShowResults();
  }

  void clear() {
    resultFilter.clear();
    filteredPlaces.clear();
  }

  void filterAndSortPlaces(SortPlaces sortby) {
    resultFilter.sortBy = sortby;
    filteredPlaces = resultFilter.filter(placesToShow);
  }

  void onSearchFinished(Places places) {
    foundPlaces = places;
    placesToShow = places;

    for(var place in places.places.values) {
      if(favoritePlaces.contains(place.id)) {
        place.isFavorite = true;
      }
    }
    filterAndShowResults();
  }
/*
  void onShowFavorites(Places places) {
    placesToShow = places;
    filterAndShowResults();
  }*/


  void filterAndShowResults() {
    filteredPlaces = resultFilter.filter(placesToShow);
    onUpdateMarkers(filteredPlaces);

  }

  void resultFilterCnt() => resultFilter.cntVisible(placesToShow);

  double resultFilterGetSliderValueRating() => resultFilter.adjustedRating(placesToShow.minRating, placesToShow.maxRating);
  double resultFilterGetSliderValueMinRating() => placesToShow.minRating;
  double resultFilterGetSliderValueMaxRating() => placesToShow.maxRating;
  void resultFilterSetRating(double value) {
    resultFilter.rating = value;
    resultFilterCnt();
  }

  double resultFilterGetSliderValueRatingCnt() => resultFilter.adjustedRatingCnt(placesToShow.minUserRatingCnt, placesToShow.maxUserRatingCnt).toDouble();
  double resultFilterGetSliderValueMinRatingCnt() => placesToShow.minUserRatingCnt.toDouble();
  double resultFilterGetSliderValueMaxRatingCnt() => placesToShow.maxUserRatingCnt.toDouble();
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