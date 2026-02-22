// Copyright 2026 Stefan Schmidt
import 'package:aroundme/settings.dart';
import 'package:flutter/cupertino.dart';
import 'file_dialog.dart';

class FavoritesDialog {
  static Future<String?> loadFavorites(BuildContext context) async {
    String? filename = await FileHelper.pickFileFromAppFolder(context);
    if (filename != null) {
      Settings.setFavoriteFile(filename);
    }
    return filename;
  }

  static Future<String?> saveFavoritesAs(BuildContext context) async {
    String? filename = await FileHelper.createNewFile(context);
    if (filename != null) {
      Settings.setFavoriteFile(filename);
    }
    return filename;
  }
}
