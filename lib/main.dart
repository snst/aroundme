import 'dart:collection';
import 'dart:convert';
import 'package:aroundme/quick_edit_tile.dart';
import 'package:aroundme/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_dynamic_key/google_map_dynamic_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiKey = prefs.getString('api_key');
  if (apiKey != null && apiKey.isNotEmpty) {
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
  String? _apiKey;


  @override
  State<AroundMePage> createState() => _AroundMePageState();
}

class _AroundMePageState extends State<AroundMePage> {
  List<dynamic> _places = [];
  List<dynamic> _filteredPlaces = [];
  List<String> _placesIds = [];
  bool _isMapReady = false;
  static const LatLng _defaultLoc = LatLng(49.4790322,11.1208134);
  LatLng _initialCenter = _defaultLoc;
  LatLng _currentMapCenter = _defaultLoc;
  double _currentRating = 1;
  double _currentUserRatingCnt = 1;
  String _nextPageToken = "";
  double _minRating = 0.0;
  double _maxRating = 0.0;
  int _maxMarkerUserRatingCnt = 0;
  int _minMarkerUserRatingCnt = 0;
  int _maxUserRatingCnt = 0;
  int _minUserRatingCnt = 0;
  int _ratingShowCnt = 0;
  int _ratingFilterCnt = 0;
  int _recessionShowCnt = 0;
  int _recessionFilterCnt = 0;

  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LatLngBounds? _mapBounds;
  final TextEditingController _searchController = TextEditingController();

  void _clearNextPageToken()
  {
    _nextPageToken = "";
  }

  void _clearResults()
  {
    setState(() {
      _places.clear();
      _placesIds.clear();
      _updateFilteredPlacesAndMarkers();
      _clearNextPageToken();
    });
  }

  Future<void> _searchNearby() async {
    /*setState(() {
      if (nextPageToken.isEmpty) {
        _places.clear();
        _filteredPlaces.clear();
        _placesMap.clear();
        _markers.clear();
      }
      _isLoading = true;
    });
*/
    // API Endpoint for Nearby Search (New)

    // Request Body
    /*
    final url = Uri.parse('https://places.googleapis.com/v1/places:searchNearby');
    final Map<String, dynamic> body = {
      "includedTypes": [keyword], // This acts as the primaryType filter
      "maxResultCount": 10,
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": _currentMapCenter.latitude,
            "longitude": _currentMapCenter.longitude,
          },
          "radius": _currentDistance * 1000 // Radius in meters
        }
      }
    };*/

    final url = Uri.parse('https://places.googleapis.com/v1/places:searchText');
    Map<String, dynamic> body = {
      "textQuery": _searchController.text, // This acts as the primaryType filter
//      "minRating": _currentRating,
      "pageSize": 10,
      "locationRestriction": {
        "rectangle": {
          "low": {
            "latitude": _mapBounds!.southwest.latitude,
            "longitude": _mapBounds!.southwest.longitude
          },
          "high": {
            "latitude": _mapBounds!.northeast.latitude,
            "longitude": _mapBounds!.northeast.longitude
          }
        }
      }
    };

    if (_nextPageToken.isNotEmpty) {
      body["pageToken"] = _nextPageToken;
    }

    if (widget._apiKey != null) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': widget._apiKey!,
            // ⚠️ IMPORTANT: Field Mask defines what data is returned
            'X-Goog-FieldMask': 'places.displayName,places.rating,places.userRatingCount,nextPageToken,places.location,places.googleMapsUri,places.googleMapsLinks,places.id,places.attributions,places.movedPlace'
          },
          body: json.encode(body),
        );
//             'X-Goog-FieldMask': 'places.displayName,places.rating,places.userRatingCount,places.formattedAddress'
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            List<dynamic> places = data['places'] ?? [];
            _nextPageToken = data['nextPageToken'] ?? "";
            //for (var place in places) {
            //  _placesMap[place['id']] = place;
            //}
            for (var place in places) {
              var id = place['id'];
              if (!_placesIds.contains(id)) {
                _placesIds.add(id);
                _places.add(place);
              }
            }
            _updateFilteredPlacesAndMarkers();
          });
        } else {
          debugPrint("Error: ${response.body}");
          throw Exception("Failed to load places");
        }
      } catch (e) {
        //setState(() => _isLoading = false);
        debugPrint(e.toString());
      }
    }
  }

  void _updateFilteredPlacesAndMarkers()
  {
    _ratingShowCnt = 0;
    _ratingFilterCnt = 0;
    _recessionShowCnt = 0;
    _recessionFilterCnt = 0;
    _minUserRatingCnt = -1;
    _maxUserRatingCnt = 0;
    _maxMarkerUserRatingCnt = 0;
    _minMarkerUserRatingCnt = -1;
    _minRating = -1;
    _maxRating = 0;
    _filteredPlaces.clear();
    for(var place in _places) {
      int add = 0;
      int userRatingCount = place['userRatingCount'] ?? 0;
      double rating = place['rating'].toDouble() ?? 0.0;

      if (rating >= _currentRating) {
        _ratingShowCnt++;
        add++;
      } else {
        _ratingFilterCnt++;
      }

      if(userRatingCount >= _currentUserRatingCnt) {
        _recessionShowCnt++;
        add++;
      } else {
        _recessionFilterCnt++;
      }

      if (userRatingCount > _maxUserRatingCnt)
      {
        _maxUserRatingCnt = userRatingCount;
      }
      if (_minUserRatingCnt == -1 || userRatingCount < _minUserRatingCnt)
      {
        _minUserRatingCnt = userRatingCount;
      }


      if (rating > _maxRating)
      {
        _maxRating = rating;
      }
      if (_minRating == -1 || rating < _minRating)
      {
        _minRating = rating;
      }

      if (add == 2) {
        _filteredPlaces.add(place);
        if (userRatingCount > _maxMarkerUserRatingCnt)
        {
          _maxMarkerUserRatingCnt = userRatingCount;
        }
        if (_minMarkerUserRatingCnt == -1 || userRatingCount < _minMarkerUserRatingCnt)
        {
          _minMarkerUserRatingCnt = userRatingCount;
        }

      }
    }

    if (_currentRating < _minRating)
      _currentRating = _minRating;
    else if (_currentRating > _maxRating)
      _currentRating = _maxRating;

    if (_currentUserRatingCnt < _minUserRatingCnt)
      _currentUserRatingCnt = _minUserRatingCnt.toDouble();
    else if (_currentUserRatingCnt > _maxUserRatingCnt)
      _currentUserRatingCnt = _maxUserRatingCnt.toDouble();

    _updateMarkers();
  }

  double calculateHue(int cnt) {
    double startHue = 240.0; // Blue
    double endHue = 360.0;   // Red (360 is the same as 0)

    // Linearly interpolate between Blue and Red
    double hue = startHue + (endHue - startHue) * ((cnt - _minMarkerUserRatingCnt) / (_maxMarkerUserRatingCnt - _minMarkerUserRatingCnt - 1));

    return hue % 360; // Ensure it stays within 0-359
  }

  void _updateMarkers()
  {
    _markers.clear();
    for (int i = 0; i < _filteredPlaces.length; i++) {
      final place = _filteredPlaces[i];

      _markers.add(
        Marker(
          markerId: MarkerId(place['id']),
          position: LatLng(place['location']['latitude'], place['location']['longitude']),
          icon: BitmapDescriptor.defaultMarkerWithHue(calculateHue(place['userRatingCount'])),
          infoWindow: InfoWindow(
            title: place['displayName']['text'],
            snippet: "${place['rating']} (${place['userRatingCount']})",
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLastPosition();
    //_loadApiKey();
  }
/*
  void _onApiKeySaved(String userEnteredKey) async {
    final dynamicKeyPlugin = GoogleMapDynamicKey();

    try {
      // This injects the key into the native SDK at runtime
      await dynamicKeyPlugin.setGoogleApiKey(userEnteredKey);

      setState(() {
        // Now you can safely show the GoogleMap widget
        _isMapReady = true;
      });
    } catch (e) {
      print("Failed to set API Key: $e");
    }
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('api_key');
      _onApiKeySaved(_apiKey ?? '');
    });
  }
*/
  // 1. Load coordinates from storage on startup
  Future<void> _loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble('map_lat');
    double? lng = prefs.getDouble('map_lng');

    setState(() {
      if (lat != null && lng != null) {
          _initialCenter = LatLng(lat, lng);
          _currentMapCenter = _initialCenter;
          //print("Loaded position: ${_currentMapCenter.latitude}, ${_currentMapCenter.longitude}");
      }
      _isMapReady = true;
    });
  }

  // 2. Save coordinates to storage
  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('map_lat', _currentMapCenter.latitude);
    await prefs.setDouble('map_lng', _currentMapCenter.longitude);
    print("Saved position: ${_currentMapCenter.latitude}, ${_currentMapCenter.longitude}");
  }

  void _onMapMoved () async
  {
    _savePosition();
    if (_mapController != null) {
      // Get the bounds (SW and NE corners)
      _mapBounds = await _mapController!.getVisibleRegion();
    }

  }

  @override
  Widget build(BuildContext context) {
    //if (widget._apiKey==null || widget._apiKey!.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    print("Create map: ${_currentMapCenter.latitude}, ${_currentMapCenter.longitude}");
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
          // 1. The Google Map Widget
          if (_isMapReady)
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _initialCenter,
              zoom: 12.0,
            ),
            markers: _markers,
            // This updates every time the map moves
            onCameraMove: (CameraPosition position) {
              _clearNextPageToken();
              //setState(() {
                _currentMapCenter = position.target;
              //});
            },
            onCameraIdle: () {
              _onMapMoved();
            },
          ),

          // 2. A visual "crosshair" or marker in the center of the screen
  /*        const Center(
            child: Icon(Icons.location_searching, size: 40, color: Colors.blue),
          ),
*/
          Positioned(
            top: 45,
            left: 20,
            right: 20,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for places...',
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
                    // Rebuild to hide the icon after clearing
                    setState(() {});
                  },
                ),
              ),
              controller: _searchController,
              onSubmitted: (value) {
                //print("Final search term: $value");
                _clearNextPageToken();
                _clearResults();
                _searchNearby();
                //performHeavySearch(value);
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
            QuickEditTile(
              title: "Rating",
              value: _currentRating,
              min: _minRating,
              max: _maxRating,
              isInt: false,
              unit: "",
              info: "+${_ratingShowCnt} -${_ratingFilterCnt}",
              onChanged: (newValue) {
                setState(() {
                  _clearNextPageToken();
                  _currentRating = newValue;
                  _updateFilteredPlacesAndMarkers();
                });
              },
            ),


            QuickEditTile(
              title: "Recessions",
              value: _currentUserRatingCnt,
              min: _minUserRatingCnt.toDouble(),
              max: _maxUserRatingCnt.toDouble(),
              isInt: true,
              unit: "",
              info: "+${_recessionShowCnt} -${_recessionFilterCnt}",
              onChanged: (newValue) {
                setState(() {
                  _currentUserRatingCnt = newValue;
                  _updateFilteredPlacesAndMarkers(); } );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 38),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () { _clearResults();},
            ),

            IconButton(
              icon: Icon(Icons.add_circle, size: 38),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () { _searchNearby();},
            ),
          ]
      )),

          /*
          DraggableScrollableSheet(
            initialChildSize: 0.3, // Start at 30% height
            minChildSize: 0.05,     // Can collapse to a small bar
            maxChildSize: 0.5,     // Can expand to almost full screen
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: 50, height: 5,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),



                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuickEditTile(
                          title: "Rating",
                          value: _currentRating,
                          min: 0,
                          max: 5,
                          unit: "",
                          onChanged: (newValue) {
                            setState(() { _currentRating = newValue; _updateFilteredPlaces();  }   );
                          },
                        ),


                        QuickEditTile(
                          title: "Recessions",
                          value: _currentUserRatingCnt,
                          min: 0,
                          max: _maxUserRatingCnt,
                          unit: "",
                          onChanged: (newValue) {
                            setState(() { _currentUserRatingCnt = newValue; _updateFilteredPlaces(); } );
                          },
                        ),


                        QuickEditTile(
                          title: "Distance",
                          value: _currentDistance,
                          min: 0.1,
                          max: 50,
                          unit: "km",
                          onChanged: (newValue) {
                            setState(() => _currentDistance = newValue);
                          },
                        ),
            ]
                    ),




                    const Divider(height: 40),

                    _isLoading
                        ? const Expanded(child: Center(child: CircularProgressIndicator()))
                        :
                    // We use ListView.builder with shrinkWrap because it's inside another ListView
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Let the parent handle scrolling
                      itemCount: _filteredPlaces.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _filteredPlaces.length) {
                          final place = _filteredPlaces[index];

                          // Note: New API uses 'displayName' object and 'userRatingCount'
                          final name = place['displayName']?['text'] ?? "Unknown";
                          final rating = place['rating'] ?? 0.0;
                          final ratingCount = place['userRatingCount'] ?? 0;
                          final address = ""; //place['formattedAddress'] ?? "";

                          return ListTile(
                            title: Text(name),
                            subtitle: Text(address),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("⭐ $rating"),
                                Text("($ratingCount)", style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          );
                        } else {

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child:
                            _nextPageToken.isEmpty ? Text("No more results") :

                            ElevatedButton(
                              onPressed: () {
                                // Your logic to fetch more data
                                print("Loading more...");
                                _searchNearby(_nextPageToken);
                              },
                              child: Text("Load More"),
                            ),
                          );
                        }

                      },
                    ),

                  ],
                ),
              );
            },
          ),
*/


          /*
          // 3. UI to display the current coordinates
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Center: ${_currentMapCenter.latitude.toStringAsFixed(5)}, '
                      '${_currentMapCenter.longitude.toStringAsFixed(5)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
          */
        ],
      ),
    );
  }

}
