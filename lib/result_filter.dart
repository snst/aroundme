// Copyright 2026 Stefan Schmidt
import 'package:aroundme/places.dart';

enum SortPlaces {
  rating,
  ratingCnt,
}

class ResultFilter {
  double rating = 0;
  int ratingCnt = 0;

  int matchRating = 0;
  int matchRatingCnt = 0;
  int visible = 0;
  int all = 0;
  SortPlaces sortBy = SortPlaces.ratingCnt;

  void clear()
  {
    rating = 0;
    ratingCnt = 0;
  }

  double adjustedRating(double minVal, double maxVal) {
    if (rating > maxVal) rating = maxVal;
    if (rating < minVal) rating = minVal;
    return rating;
  }

  int adjustedRatingCnt(int minVal, int maxVal) {
    if (ratingCnt > maxVal) ratingCnt = maxVal;
    if (ratingCnt < minVal) ratingCnt = minVal;
    return ratingCnt;
  }

  void cntVisible(Places places) {
    visible = matchRating = matchRatingCnt = 0;
    all = places.items.length;
    for (final place in places.items) {
      if (place.rating >= rating && place.userRatingCnt >= ratingCnt) {
        visible++;
      }
      if (place.rating >= rating) {
        matchRating++;
      }
      if (place.userRatingCnt >= ratingCnt) {
        matchRatingCnt++;
      }
    }
  }

  Places filter(Places places) {
    cntVisible(places);
    Places filteredPlaces = Places();
    for (final place in places.items) {
      if (place.rating >= rating && place.userRatingCnt >= ratingCnt) {
        filteredPlaces.add(place);
      }
    }
    if (sortBy == SortPlaces.ratingCnt) {
      filteredPlaces.items.sort((a, b) => b.userRatingCnt.compareTo(a.userRatingCnt));
    } else if (sortBy == SortPlaces.rating) {
      filteredPlaces.items.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return filteredPlaces;
  }
}
