import 'package:aroundme/FavoritePlaces.dart';
import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter.dart';

class AppData
{
  ResultFilter resultFilter = ResultFilter();
  Places searchResults = Places();
  Places filteredSearchResults = Places();
  Places placeStorage = Places();

  void clear()
  {
    resultFilter.ratingCnt = 0;
    resultFilter.rating = 0;
    filteredSearchResults.clear();
  }

  void filterAndSortPlaces(SortPlaces sortby) {
    resultFilter.sortBy = sortby;
    filteredSearchResults = resultFilter.filter(searchResults);
  }

  void onSearchFinished(Places places) {
    searchResults = places;

    for(var place in places.places.values) {
      if(placeStorage.contains(place.id)) {
        place.isFavorite = true;
      }
    }

    updateFilteredSearchResults();
  }

  void setAndShowFavorites(Places places) {
    searchResults.copyFrom(places);
    updateFilteredSearchResults();
  }

  void updateFilteredSearchResults() {
    filteredSearchResults = resultFilter.filter(searchResults);
  }


  void resultFilterCnt() => resultFilter.cntVisible(searchResults);

  double resultFilterGetSliderValueRating() => resultFilter.adjustedRating(searchResults.minRating, searchResults.maxRating);
  double resultFilterGetSliderValueMinRating() => searchResults.minRating;
  double resultFilterGetSliderValueMaxRating() => searchResults.maxRating;
  void resultFilterSetRating(double value) {
    resultFilter.rating = value;
    resultFilterCnt();
  }

  double resultFilterGetSliderValueRatingCnt() => resultFilter.adjustedRatingCnt(searchResults.minUserRatingCnt, searchResults.maxUserRatingCnt).toDouble();
  double resultFilterGetSliderValueMinRatingCnt() => searchResults.minUserRatingCnt.toDouble();
  double resultFilterGetSliderValueMaxRatingCnt() => searchResults.maxUserRatingCnt.toDouble();
  void resultFilterSetRatingCnt(double value) {
    resultFilter.ratingCnt = value.toInt();
    resultFilterCnt();
  }

  void resultFilterClearMinValues() {
    resultFilter.rating = searchResults.minRating;
    resultFilter.ratingCnt = searchResults.minUserRatingCnt;
    resultFilter.cntVisible(searchResults);
  }


}