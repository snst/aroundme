// Copyright 2026 Stefan Schmidt
import 'package:aroundme/settings.dart';
import 'package:flutter/material.dart';

import 'favorites_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onSaveFavorites, required this.onLoadFavorites});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
  final Function onSaveFavorites;
  final Function onLoadFavorites;
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  String? _apiKey;
  String? _favoriteFile;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _loadsettings();
  }

  Future<void> _loadsettings() async {
    _apiKey = await Settings.getApiKey();
    _favoriteFile = await Settings.getFavoriteFile();
    setState(() {
      _apiKeyController.text = _apiKey ?? '';
    });
  }

  Future<void> _saveApiKey() async {
    _apiKey = _apiKeyController.text;
    await Settings.setApiKey(_apiKey!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key Saved!')));
  }

  Future<void> loadFavorites(BuildContext context) async {
    String? filename = await FavoritesDialog.loadFavorites(context);
    if (filename != null) {
      setState(() {
        _favoriteFile = filename;
      });
      widget.onLoadFavorites(fullPath: filename);
    }
  }

  Future<void> saveFavorites(BuildContext context) async {
    widget.onSaveFavorites(_favoriteFile);
  }

  Future<void> saveFavoritesAs(BuildContext context) async {
    String? filename = await FavoritesDialog.saveFavoritesAs(context);
    if (filename != null) {
      setState(() {
        _favoriteFile = filename;
      });
      widget.onSaveFavorites(filename);
    }
  }

  /*
    Future<void> saveSettingsAndFile(BuildContext context) async {

      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null) {
        return;
      }

        String? fileName = await showDialog<String>(
          context: context,
          builder: (context) {
            TextEditingController _controller = TextEditingController(text: "");
            return AlertDialog(
              title: Text("Enter Filename"),
              content: TextField(controller: _controller, decoration: InputDecoration(suffixText: ".json")),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                ElevatedButton(onPressed: () => Navigator.pop(context, _controller.text), child: Text("Save")),
              ],
            );
          }
      );

      if (fileName == null || fileName.isEmpty) return;

      String fullPath = "$directoryPath/$fileName.json";
      if(!fullPath.endsWith('.json')) {
        fullPath += '.json';
      }
      setState(() {
        _favoriteFileController.text = fullPath;
      });
      Settings.setFavoriteFile(fullPath);
      widget.onSaveFavorites(fullPath);
    }
    */

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
            Text(_favoriteFile ?? ""),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    loadFavorites(context);
                  },
                  child: const Text('Load'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    saveFavorites(context);
                  },
                  child: const Text('Save'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    saveFavoritesAs(context);
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
