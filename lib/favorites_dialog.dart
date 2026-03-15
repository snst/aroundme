// Copyright 2026 Stefan Schmidt
import 'package:flutter/cupertino.dart';
import 'file_dialog.dart';

class FavoritesDialog {
  static Future<String?> showDlgLoadFavorites(BuildContext context) async {
    String? filename = await FileHelper.pickFileFromAppFolder(context);
    return filename;
  }

  static Future<String?> showDlgSaveFavoritesAs(BuildContext context) async {
    String? filename = await FileHelper.createNewFile(context);
    return filename;
  }
}
