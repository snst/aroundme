// Copyright 2026 Stefan Schmidt
import 'package:aroundme/settings.dart';
import 'package:flutter/material.dart';

import 'favorites_dialog.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key, required this.favoriteFile,
    required this.onSaveFavorites,
    required this.onSaveNewFavorites,
    required this.onLoadFavorites
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
  String favoriteFile;
  final Function onSaveFavorites;
  final Function onSaveNewFavorites;
  final Function onLoadFavorites;
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _loadsettings();
  }

  Future<void> _loadsettings() async {
    _apiKey = await Settings.getApiKey();
    setState(() {
      _apiKeyController.text = _apiKey ?? '';
    });
  }

  Future<void> _saveApiKey() async {
    _apiKey = _apiKeyController.text;
    await Settings.setApiKey(_apiKey!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key Saved!')));
  }

  void loadFavorites(BuildContext context) async {
    String? filename = await FavoritesDialog.showDlgLoadFavorites(context);
    if (filename != null) {
      widget.onLoadFavorites(filename);
    }
  }

  Future<void> saveFavorites(BuildContext context) async {
    widget.onSaveFavorites(widget.favoriteFile);
  }

  Future<void> saveFavoritesAs(BuildContext context) async {
    String? filename = await FavoritesDialog.showDlgSaveFavoritesAs(context);
    widget.onSaveFavorites(filename);
  }

  Future<void> saveNewFavoritesAs(BuildContext context) async {
    String? filename = await FavoritesDialog.showDlgSaveFavoritesAs(context);
    widget.onSaveNewFavorites(filename);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('API Key', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter your API key'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveApiKey, child: const Text('Save')),

            const Text('Favorites File', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.favoriteFile ?? ""),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    loadFavorites(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Load'),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    saveNewFavoritesAs(context);
                    Navigator.pop(context);
                  },
                  child: const Text('New'),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    saveFavorites(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    saveFavoritesAs(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Save As'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
