import 'package:aroundme/map_search.dart';
import 'package:aroundme/places.dart';
import 'package:aroundme/result_filter.dart';
import 'package:aroundme/settings.dart';
import 'package:aroundme/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_map_dynamic_key/google_map_dynamic_key.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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
  AroundMePage({super.key, required this.title, required String? apiKey}) : _apiKey = apiKey;

  final String title;
  final String? _apiKey;

  @override
  State<AroundMePage> createState() => _AroundMePageState();
}

class _AroundMePageState extends State<AroundMePage> {
  //FilterData filter = FilterData();
  late final MapSearch mapSearch;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng? mapCenter;
  bool isMapReady = false;
  Set<Marker> markers = {};
  ResultFilter resultFilter = ResultFilter();
  Places searchResults = Places();


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

  double calculateHue(int minCnt, int maxCnt, int cnt) {
    double startHue = 240.0; // Blue
    double endHue = 360.0; // Red (360 is the same as 0)

    // Linearly interpolate between Blue and Red
    double div = (maxCnt - minCnt - 1);
    if (div == 0) {
      return 360;
    }
    double hue = startHue + (endHue - startHue) * ((cnt - minCnt) / div);
    return hue % 360; // Ensure it stays within 0-359
  }

  void updateMarkers(Places places) {
    setState(() {

    markers.clear();
    for (final place in places.items) {
      markers.add(
        Marker(
          markerId: MarkerId(place['id']),
          position: LatLng(place['location']['latitude'], place['location']['longitude']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            calculateHue(places.minUserRatingCnt, places.maxUserRatingCnt, place['userRatingCount'] ?? 0),
          ),
          //icon: BitmapDescriptor.defaultMarkerWithHue(300),
          infoWindow: InfoWindow(
            title: place['displayName']['text'],
            snippet: "${place['rating'] ?? '?'} (${place['userRatingCount'] ?? '?'})",
          ),
        ),
      );
    }
    });

  }

  void clearResults() {
    setState(() {
      mapSearch.clearResults();
      markers.clear();
      resultFilter.filter(mapSearch.places);
      //filter.updateFilteredPlacesAndMarkers(mapSearch.places);
    });
  }

  void onMapMoved() async {
    Settings.setInitialPos(mapCenter!);
    if (_mapController != null) {
      mapSearch.setMapBounds(await _mapController!.getVisibleRegion());
    }
  }

  void onSearchFinished(Places places, bool hasMore) {
      searchResults = places;
      updateMarkers(resultFilter.filter(searchResults));
      if (!hasMore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No more results.'),
            duration: const Duration(seconds: 2), // How long it stays
            behavior: SnackBarBehavior.floating, // Makes it float above the bottom
          ),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    //if (widget._apiKey==null || widget._apiKey!.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    //print("Create map: ${filter.currentMapCenter.latitude}, ${filter.currentMapCenter.longitude}");
    return Scaffold(
      resizeToAvoidBottomInset: false,

      /*
      appBar: AppBar(title: const Text('Map Center Coordinate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],),*/
      body: Stack(
        children: [
          if (isMapReady)
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(target: mapCenter!, zoom: 12.0),
              markers: markers,
              padding: const EdgeInsets.only(top: 150),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onCameraMove: (CameraPosition position) {
                //filter.clearNextPageToken();
                mapCenter = position.target;
              },
              onCameraIdle: () {
                onMapMoved();
              },
            ),

          Positioned(
            top: 45,
            left: 20,
            right: 20,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
              ),
              controller: _searchController,
              onSubmitted: (value) {
                clearResults();
                mapSearch.search(_searchController.text, true);
              },
            ),
          ),

          Positioned(
            top: 105,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  "# ${markers.length} / ${resultFilter.all}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                IconButton(
                  icon: Icon(Icons.settings, size: 38),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );

                  },
                ),
                IconButton(
                  icon: Icon(Icons.filter_alt, size: 38),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder( // Allows the slider to move inside the dialog
                          builder: (context, setDialogState) {
                            resultFilter.cntVisible(searchResults);
                            return AlertDialog(
                              title: Text("Results: ${resultFilter.visible} / ${resultFilter.all}"),
                              content:
                              Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Rating: ${resultFilter.rating.toStringAsFixed(1)} (${resultFilter.matchRating})",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                                ),
                                Slider(
                                  value: resultFilter.adjustedRating(searchResults.minRating, searchResults.maxRating),
                                  min: searchResults.minRating,
                                  max: searchResults.maxRating,
                                  onChanged: (value) { setDialogState(() {
                                    resultFilter.rating = value;
                                    resultFilter.cntVisible(searchResults);
                                  }); },
                                ),
                                SizedBox(height:20),
                                Text(
                                  "Ratings: ${resultFilter.ratingCnt} (${resultFilter.matchRatingCnt})",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                                ),
                                Slider(
                                  value: resultFilter.adjustedRatingCnt(searchResults.minUserRatingCnt, searchResults.maxUserRatingCnt).toDouble(),
                                  min: searchResults.minUserRatingCnt.toDouble(),
                                  max: searchResults.maxUserRatingCnt.toDouble(),
                                  onChanged: (value) { setDialogState(() {
                                    resultFilter.ratingCnt = value.toInt();
                                    resultFilter.cntVisible(searchResults);
                                  }); },
                                ),
                              ],
                            ), //FilterWidget(valText: valText, widget: widget, tempValue: tempValue),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    //widget.onChanged(tempValue);
                                    updateMarkers(resultFilter.filter(searchResults));
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
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 38),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    clearResults();
                  },
                ),

                IconButton(
                  icon: Icon(Icons.add_circle, size: 38),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    mapSearch.search(_searchController.text, false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
