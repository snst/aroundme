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
  String favoriteFile = "";

  Future<void> init()
  async {
    favoriteFile = await Settings.getFavoriteFile();
    loadFavorites(favoriteFile);
  }

  void setSearchMode(SearchMode searchMode) {
    this.searchMode = searchMode;
    if (searchMode == SearchMode.favorite) {
      showFavorites();
    }
    else if (searchMode == SearchMode.search) {
      showLastSearchResults();
    }
  }

  void showFavorites() {
    favoritePlaces.updateMinMaxValues();
    placesToShow = favoritePlaces;
    filterAndShowResults();
  }

  void updateFavoriteFilename(String? fullPath) {
    if (fullPath != null && favoriteFile != fullPath) {
      favoriteFile = fullPath;
      Settings.setFavoriteFile(favoriteFile);
    }
  }

  void clearFavorites()
  {
    favoritePlaces.clear();
    updateShownFavoritesIfVisible();
  }

  void loadFavorites(String? fullPath) async {
    updateFavoriteFilename(fullPath);
    if (favoriteFile != "") {
      File file = File(favoriteFile);
      String jsonString = await file.readAsString();
      favoritePlaces.fromJson(jsonString);
      favoritePlaces.isDirty = false;
    }
    updateShownFavoritesIfVisible();
  }

  void saveFavorites(String? fullPath) async {
    updateFavoriteFilename(fullPath);
    if (favoriteFile != "") {
      String jsonString = favoritePlaces.toJson();
      File(favoriteFile).writeAsStringSync(jsonString);
      favoritePlaces.isDirty = false;
    }
  }

  void saveFavoritesIfChanged()
  {
    if (favoritePlaces.isDirty) {
      saveFavorites(null);
    }
  }

  void updateShownFavoritesIfVisible()
  {
    if (searchMode == SearchMode.favorite) {
      showFavorites();
    }
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