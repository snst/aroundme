// Copyright 2026 Stefan Schmidt
import 'dart:io';

import 'package:aroundme/app_data.dart';
import 'package:aroundme/favorite_search_picker.dart';
import 'package:aroundme/map_search.dart';
import 'package:aroundme/place_list_widget.dart';
import 'package:aroundme/place_popup.dart';
import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter_dialog.dart';
import 'package:aroundme/settings.dart';
import 'package:aroundme/settings_screen.dart';
import 'package:aroundme/text_marker_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_map_dynamic_key/google_map_dynamic_key.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'FavoritePlaces.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String apiKey = await Settings.getApiKey();
  if (apiKey.isNotEmpty) {
    await GoogleMapDynamicKey().setGoogleApiKey(apiKey);
  }
  runApp(AroundMeApp(apiKey: apiKey));
}

class AroundMeApp extends StatelessWidget {
  const AroundMeApp({super.key, required String? apiKey}) : _apiKey = apiKey;
  final String? _apiKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AroundMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: AroundMePage(title: 'AroundMe', apiKey: _apiKey),
    );
  }
}

class AroundMePage extends StatefulWidget {
  const AroundMePage({super.key, required this.title, required String? apiKey}) : _apiKey = apiKey;

  final String title;
  final String? _apiKey;

  @override
  State<AroundMePage> createState() => _AroundMePageState();
}

class _AroundMePageState extends State<AroundMePage> {
  late final MapSearch mapSearch;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng? mapCenter;
  bool isMapReady = false;
  AppData data = AppData();
  EdgeInsets _mapPadding = const EdgeInsets.only(top: 400);
  bool _isPlacesListVisible = false;
  Set<Marker> markers = {};


  @override
  void initState() {
    super.initState();
    mapSearch = MapSearch(widget._apiKey, onSearchFinished);
    _init();
  }

  Future<void> _init() async {
    await _requestLocationPermission();
    final center = await Settings.getInitialPos();
    setState(() {
      mapCenter = center;
      isMapReady = true;
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      // Handle the case where the user denies the permission.
    }
  }

  Future<Set<Marker>> _buildMarkers(Places places) async {
    final newMarkers = <Marker>{};
    for (final place in places.places.values) {
      Color color = place.isFavorite ? Colors.green : Color.lerp(Colors.blue, Colors.red, places.normRatingCnt(place.userRatingCnt))!;
      final icon = await createCustomMarkerBitmap(
        "${place.rating}",
        color,
      );
      newMarkers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: place.location,
          icon: icon,
          infoWindow: InfoWindow(
            title: place.name,
            snippet: "${place.rating} (${place.userRatingCnt})",
            onTap: () {
              showPlacePopup(context, place, toggleFavorite);
            },
          ),
        ),
      );
    }
    return newMarkers;
  }

  void clearResults() {
    setState(() {
      mapSearch.clearResults();
      mapSearch.clearNextPageToken();
      markers.clear();
      data.clear();
    });
  }

  void onMapMoved() async {
    Settings.setInitialPos(mapCenter!);
    if (_mapController != null) {
      mapSearch.setMapBounds(mapCenter!, await _mapController!.getVisibleRegion());
    }
  }

  void updateMarkers(Places places) async {
    final newMarkers = await _buildMarkers(places);
    if (!mounted) return;
    setState(() {
      markers = newMarkers;
    });
  }

  void onSearchFinished(Places places, bool hasMore) async {
    data.onSearchFinished(places);
    updateMarkers(data.filteredSearchResults);
    if (!hasMore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more results.'),
          duration: Duration(seconds: 2), // How long it stays
          behavior: SnackBarBehavior.floating, // Makes it float above the bottom
        ),
      );
    }
  }

  void _togglePlacesList() {
    setState(() {
      _isPlacesListVisible = !_isPlacesListVisible;
      if (_isPlacesListVisible) {
        final screenHeight = MediaQuery.of(context).size.height;
        _mapPadding = EdgeInsets.only(top: 400, bottom: screenHeight * 0.5);
      } else {
        _mapPadding = const EdgeInsets.only(top: 400);
      }
    });
  }

  void toggleFavorite(Place place) {
    place.isFavorite = !place.isFavorite;
    if (place.isFavorite) {
      data.placeStorage.add(place);
    } else {
      data.placeStorage.remove(place.id);
    }

    updateMarkers(data.filteredSearchResults);
  }

  void _saveFavorites(String fullPath)
  {
    try {
      String jsonString = data.placeStorage.toJson();
      print(jsonString);

      File(fullPath).writeAsStringSync(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved: $fullPath"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _loadFavorites() async
  {
    if (data.placeStorage.isEmpty()) {
      String fullPath = await Settings.getFavoriteFile();
      File file = File(fullPath);
      String jsonString = await file.readAsString();
      data.placeStorage.fromJson(jsonString);
    }
    data.setAndShowFavorites(data.placeStorage);
    updateMarkers(data.filteredSearchResults);
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Colors.black.withOpacity(0.6);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (isMapReady)
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(target: mapCenter!, zoom: 12.0),
              markers: markers,
              padding: _mapPadding,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onCameraMove: (CameraPosition position) {
                mapCenter = position.target;
              },
              onCameraIdle: () {
                onMapMoved();
              },
            ),
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 100),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8.0),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                ),
                        ),
                        controller: _searchController,
                        onSubmitted: (value) {
                          clearResults();
                          mapSearch.searchText(_searchController.text);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => showFilterDialog(context, data, updateMarkers),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(230), // Light blue background
                    foregroundColor: Colors.black, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(width: 1),
                    ),
                  ),
                  child: Text("${markers.length} / ${data.resultFilter.all}"),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.delete, size: 38, color: iconColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    clearResults();
                  },
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.add_circle, size: 38, color: iconColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    mapSearch.searchNext();
                  },
                ),
                const SizedBox(height: 10),
                FavoriteSearchPicker(
                  onSelected: (value) {
                    clearResults();
                    mapSearch.searchNearby(value);
                  },
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.list, size: 38, color: iconColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _togglePlacesList,
                ),
                const SizedBox(height: 80),
                IconButton(
                  icon: Icon(Icons.file_open, size: 38, color: iconColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () { _loadFavorites(); },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.settings, size: 38, color: iconColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(onSaveFavorites: _saveFavorites)));
              },
            ),
          ),
          if (_isPlacesListVisible)
            PlaceListWidget(data: data, mapController: _mapController, onClosePressed: _togglePlacesList, onToggleFavorite: toggleFavorite)
        ],
      ),
    );
  }
}
