import 'package:aroundme/app_data.dart';
import 'package:flutter/material.dart';

void showFilterDialog(BuildContext context, AppData data) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        // Allows the slider to move inside the dialog
        builder: (context, setDialogState) {
          data.resultFilterCnt();

          return AlertDialog(
            title: Text("Results: ${data.resultFilter.visible} / ${data.resultFilter.all}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Rating: ${data.resultFilter.rating.toStringAsFixed(1)} (${data.resultFilter.matchRating})",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                Slider(
                  value: data.resultFilterGetSliderValueRating(),
                  min: data.resultFilterGetSliderValueMinRating(),
                  max: data.resultFilterGetSliderValueMaxRating(),
                  onChanged: (value) {
                    setDialogState(() => data.resultFilterSetRating(value));
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Ratings: ${data.resultFilter.ratingCnt} (${data.resultFilter.matchRatingCnt})",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                Slider(
                  value: data.resultFilterGetSliderValueRatingCnt(),
                  min: data.resultFilterGetSliderValueMinRatingCnt(),
                  max: data.resultFilterGetSliderValueMaxRatingCnt(),
                  onChanged: (value) {
                    setDialogState(() => data.resultFilterSetRatingCnt(value));
                  },
                ),
              ],
            ),
            actions: [
              // TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  setDialogState(() async {
                    data.resultFilterClearMinValues();
                    data.filterAndShowResults();
                    Navigator.pop(context);
                  });
                },
                child: const Text("Clear"),
              ),
              TextButton(
                onPressed: () async {
                  data.filterAndShowResults();
                  Navigator.pop(context);
                },
                child: const Text("Filter"),
              ),
            ],
          );
        },
      );
    },
  );
}
