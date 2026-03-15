// Copyright 2026 Stefan Schmidt
import 'package:flutter/material.dart';

import 'app_utils.dart';

class FavItem {
  final List<String> search;
  final IconData icon;
  final String title;

  FavItem({required this.search, required this.icon, required this.title});
}

final List<FavItem> favorites = [
  FavItem(search: ['restaurant'], icon: Icons.restaurant, title: 'Restaurant'),
  FavItem(search: ['fast_food_restaurant'], icon: Icons.fastfood, title: 'Fast Food'),
  FavItem(search: ['bakery'], icon: Icons.bakery_dining, title: 'Bäckerei'),
  FavItem(search: ['cafe'], icon: Icons.local_cafe, title: 'Café'),
  FavItem(search: ['bar'], icon: Icons.local_bar, title: 'Bar'),
  FavItem(search: ['museum'], icon: Icons.museum, title: 'Museum'),
  FavItem(search: ['tourist_attraction'], icon: Icons.attractions, title: 'Touristen Attraktion'),
  FavItem(search: ['public_bathroom'], icon: Icons.store, title: 'Toiletten'),
  FavItem(search: ['car_repair'], icon: Icons.car_repair, title: 'KFZ Werkstatt'),
  FavItem(search: ['gas_station'], icon: Icons.local_gas_station, title: 'Tankstelle'),
  FavItem(search: ['parking'], icon: Icons.local_parking, title: 'Parkplatz'),
  FavItem(search: ['atm'], icon: Icons.atm, title: 'ATM'),
  FavItem(search: ['bank'], icon: Icons.money, title: 'Bank'),
  FavItem(search: ['hotel', 'hostel', 'guest_house'], icon: Icons.hotel, title: 'Hotel'),
  FavItem(search: ['drugstore'], icon: Icons.medical_services, title: 'Drogerie'),
  FavItem(search: ['store'], icon: Icons.store, title: 'Store'),
  FavItem(search: ['supermarket'], icon: Icons.store, title: 'Supermarkt'),
  FavItem(search: ['shopping_mall'], icon: Icons.local_mall, title: 'Einkaufszentrum'),
  FavItem(search: ['market'], icon: Icons.store, title: 'Markt'),
  FavItem(search: ['hardware_store'], icon: Icons.store, title: 'Baumarkt'),
  FavItem(search: ['bus_station', 'bus_stop'], icon: Icons.directions_bus, title: 'Bus'),
  FavItem(search: ['train_station'], icon: Icons.train, title: 'Bahn'),
  FavItem(search: ['airport'], icon: Icons.airplanemode_active, title: 'Flughafen'),
  FavItem(search: ['swimming_pool'], icon: Icons.pool, title: 'Schwimmbad'),
  FavItem(search: ['doctor', 'hospital', 'dentist'], icon: Icons.local_hospital, title: 'Arzt'),
  FavItem(search: ['pharmacy'], icon: Icons.medication, title: 'Apotheke'),
];

class FavoriteSearchPicker extends StatefulWidget {
  const FavoriteSearchPicker({super.key, required this.onSelected, required this.isActive});
  final Function(List<String>) onSelected;
  final bool isActive;

  @override
  State<FavoriteSearchPicker> createState() => _FavoriteSearchPickerState();
}

class _FavoriteSearchPickerState extends State<FavoriteSearchPicker> {
  IconData buttonIcon = Icons.stars_rounded;

  @override
  void initState() {
    super.initState();
    favorites.sort((a, b) => a.title.compareTo(b.title));
  }

  void _showFavoriteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          //title: const Text('Select Favorite'),
          children: favorites.map((entry) {
            return SimpleDialogOption(
              onPressed: () {
                buttonIcon = entry.icon;
                widget.onSelected(entry.search);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(entry.icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 15),
                  Text(entry.title),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(buttonIcon, color: getIconColor(widget.isActive), size: 38),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: 'Search Favorites',
      onPressed: () => _showFavoriteDialog(context),
    );
  }
}
