import 'package:aroundme/app_data.dart';
import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceListWidget extends StatefulWidget {
  const PlaceListWidget({
    super.key,
    required this.data,
    required GoogleMapController? mapController,
    required this.onClosePressed
  }) : _mapController = mapController;

  final AppData data;
  final GoogleMapController? _mapController;
  final Function onClosePressed;

  @override
  State<PlaceListWidget> createState() => _PlaceListWidgetState();
}

class _PlaceListWidgetState extends State<PlaceListWidget> {
  @override
  Widget build(BuildContext context) {

    return SizedBox.expand(
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.1,
        maxChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        setState(() {
                          widget.data.filterAndSortPlaces(SortPlaces.rating);
                        });
                      },
                      color: widget.data.resultFilter.sortBy == SortPlaces.rating ? Colors.orange : Colors.grey,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.people),
                          onPressed: () {
                            setState(() {
                              widget.data.filterAndSortPlaces(SortPlaces.ratingCnt);
                            });
                          },
                          color: widget.data.resultFilter.sortBy == SortPlaces.ratingCnt ? Colors.orange : Colors.grey,
                        ),
                        SizedBox(width:10),
                        IconButton(icon: const Icon(Icons.close), onPressed: widget.onClosePressed as void Function()?),
                      ],
                    ),
                  ],
                ),
                // Scrollable list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.data.filteredSearchResults.items.length,
                    itemBuilder: (context, index) {
                      final place = widget.data.filteredSearchResults.items[index];
                      return ListTile(
                        title: Text(place.name),
                        subtitle: Text('${place.rating} (${place.userRatingCnt})'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: () {
                                launchURL(place.gmPlace);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.star),
                              //padding: EdgeInsets.zero,
                              //constraints: const BoxConstraints(),
                              onPressed: () {
                                launchURL(place.gmReviews);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          widget._mapController?.animateCamera(CameraUpdate.newLatLng(place.location));
                          widget._mapController?.showMarkerInfoWindow(MarkerId(place.id));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
