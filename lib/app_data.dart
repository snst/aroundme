// Copyright 2026 Stefan Schmidt
import 'dart:io';

import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter.dart';
import 'package:aroundme/settings.dart';

class AppData
{
  ResultFilter resultFilter = ResultFilter();
  Places _foundPlaces = Places();
  Places _favoritePlaces = Places();
  Places _filteredPlaces = Places();
  late Places _placesToShow = _foundPlaces;
  String _favoriteFile = "";
  bool _showFavorites = false;
  Function onUpdateMarkers = (Places places) {};

  bool get favoritesVisible => _showFavorites;
  String get favoriteFile => _favoriteFile;
  Places get filteredPlaces => _filteredPlaces;

  Future<void> init()
  async {
    _favoriteFile = await Settings.getFavoriteFile();
    loadFavorites(_favoriteFile);
  }

  void showFavorites(bool val) {
    _showFavorites = val;
    if (_showFavorites) {
      _favoritePlaces.updateMinMaxValues();
      _placesToShow = _favoritePlaces;
      filterAndShowResults();
    } else {
      showLastSearchResults();
    }
  }

  void updateFavoriteFilename(String fullPath) {
    if (_favoriteFile != fullPath) {
      _favoriteFile = fullPath;
      Settings.setFavoriteFile(_favoriteFile);
    }
  }

  void loadFavorites(String fullPath) async {
    updateFavoriteFilename(fullPath);
    if (_favoriteFile != "") {
      File file = File(_favoriteFile);
      String jsonString = await file.readAsString();
      _favoritePlaces.fromJson(jsonString);
      _favoritePlaces.isDirty = false;
    }
  }

  void saveFavorites() async {
    if (_favoriteFile != "") {
      String jsonString = _favoritePlaces.toJson();
      File(_favoriteFile).writeAsStringSync(jsonString);
      _favoritePlaces.isDirty = false;
    }
  }

  void saveNewFavorites(String fullPath) {
      saveFavoritesIfChanged();
      _favoritePlaces.clear();
      saveFavoritesAs(fullPath);
  }

  void saveFavoritesAs(String fullPath) async {
    updateFavoriteFilename(fullPath);
    saveFavorites();
  }

  void saveFavoritesIfChanged()
  {
    if (_favoritePlaces.isDirty) {
      saveFavorites();
    }
  }

  void toggleFavorite(Place place) {
    place.isFavorite = !place.isFavorite;
    if (place.isFavorite) {
      _favoritePlaces.add(place);
    } else {
      _favoritePlaces.remove(place.id);
    }
    _favoritePlaces.isDirty = true;
  }

  void searchFavorites(String text) {
    _placesToShow = _favoritePlaces.filterByText(text);
    filterAndShowResults();
  }

  void showLastSearchResults() {
    _placesToShow = _foundPlaces;
    filterAndShowResults();
  }

  void clear() {
    resultFilter.clear();
    _filteredPlaces.clear();
  }

  void filterAndSortPlaces(SortPlaces sortby) {
    resultFilter.sortBy = sortby;
    _filteredPlaces = resultFilter.filter(_placesToShow);
  }

  void onSearchFinished(Places places) {
    _foundPlaces = places;
    _placesToShow = places;

    for(var place in places.places.values) {
      if(_favoritePlaces.contains(place.id)) {
        place.isFavorite = true;
      }
    }
    filterAndShowResults();
  }

  void filterAndShowResults() {
    _filteredPlaces = resultFilter.filter(_placesToShow);
    onUpdateMarkers(_filteredPlaces);
  }

  void resultFilterCnt() => resultFilter.cntVisible(_placesToShow);

  double resultFilterGetSliderValueRating() => resultFilter.adjustedRating(_placesToShow.minRating, _placesToShow.maxRating);
  double resultFilterGetSliderValueMinRating() => _placesToShow.minRating;
  double resultFilterGetSliderValueMaxRating() => _placesToShow.maxRating;
  void resultFilterSetRating(double value) {
    resultFilter.rating = value;
    resultFilterCnt();
  }

  double resultFilterGetSliderValueRatingCnt() => resultFilter.adjustedRatingCnt(_placesToShow.minUserRatingCnt, _placesToShow.maxUserRatingCnt).toDouble();
  double resultFilterGetSliderValueMinRatingCnt() => _placesToShow.minUserRatingCnt.toDouble();
  double resultFilterGetSliderValueMaxRatingCnt() => _placesToShow.maxUserRatingCnt.toDouble();
  void resultFilterSetRatingCnt(double value) {
    resultFilter.ratingCnt = value.toInt();
    resultFilterCnt();
  }

  void resultFilterClearMinValues() {
    resultFilter.rating = _foundPlaces.minRating;
    resultFilter.ratingCnt = _foundPlaces.minUserRatingCnt;
    resultFilter.cntVisible(_foundPlaces);
  }
}