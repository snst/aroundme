import 'package:aroundme/app_data.dart';
import 'package:aroundme/place_popup.dart';
import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceListWidget extends StatefulWidget {
  const PlaceListWidget({
    super.key,
    required this.data,
    required GoogleMapController? mapController,
    required this.onClosePressed,
    required this.onToggleFavorite,
  }) : _mapController = mapController;

  final AppData data;
  final GoogleMapController? _mapController;
  final Function onClosePressed;
  final Function onToggleFavorite;

  @override
  State<PlaceListWidget> createState() => _PlaceListWidgetState();
}

class _PlaceListWidgetState extends State<PlaceListWidget> {
  Place? _selectedPlace;
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
                  mainAxisSize: MainAxisSize.min,
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
                    IconButton(
                      icon: const Icon(Icons.people),
                      onPressed: () {
                        setState(() {
                          widget.data.filterAndSortPlaces(SortPlaces.ratingCnt);
                        });
                      },
                      color: widget.data.resultFilter.sortBy == SortPlaces.ratingCnt ? Colors.orange : Colors.grey,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.heart_broken),
                      color: _selectedPlace != null && _selectedPlace!.isFavorite ? Colors.red : null,
                      onPressed: _selectedPlace == null
                          ? null
                          : () {
                              setState(() {
                                widget.onToggleFavorite(_selectedPlace!);
                              });
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: _selectedPlace == null
                          ? null
                          : () {
                              launchURL(_selectedPlace!.gmPlace);
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.rate_review),
                      onPressed: _selectedPlace == null
                          ? null
                          : () {
                              launchURL(_selectedPlace!.gmReviews);
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions),
                      onPressed: _selectedPlace == null
                          ? null
                          : () {
                              launchURL(_selectedPlace!.gmDirections);
                            },
                    ),

                    SizedBox(width: 20),
                    IconButton(icon: const Icon(Icons.close), onPressed: widget.onClosePressed as void Function()?),
                  ],
                ),
                // Scrollable list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.data.filteredPlaces.items.length,
                    itemBuilder: (context, index) {
                      final place = widget.data.filteredPlaces.items[index];
                      return ListTile(
                        title: Text(place.name),
                        subtitle: Text('${place.rating} (${place.userRatingCnt}) - ${place.category}'),
                        selected: _selectedPlace == place,
                        selectedTileColor: Theme.of(context).colorScheme.secondaryFixedDim,
                        //selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.heart_broken),
                              color: place.isFavorite ? Colors.red : null,
                              onPressed: () {
                                setState(() {
                                  widget.onToggleFavorite(place);
                                });
                              },
                            ),
                            /*
                            IconButton(
                              icon: const Icon(Icons.details),
                              onPressed: () {
                                //launchURL(place.gmPlace);
                                widget._mapController?.animateCamera(CameraUpdate.newLatLng(place.location));
                                widget._mapController?.showMarkerInfoWindow(MarkerId(place.id));
                                showPlacePopup(context, place, widget.onToggleFavorite);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: () {
                                launchURL(place.gmPlace);
                              },
                            )*/
                            /*IconButton(
                              icon: const Icon(Icons.star),
                              onPressed: () {
                                launchURL(place.gmReviews);
                              },
                            ),*/
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPlace = place;
                          });
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
