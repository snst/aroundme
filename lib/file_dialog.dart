// Copyright 2026 Stefan Schmidt
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class FileHelper {
  // Create new file with dialogs
  static Future<String?> createNewFile(BuildContext context, {String initialContent = ''}) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return null;

    // Ask for filename
    String? fileName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String name = '';
        return AlertDialog(
          title: Text('Enter file name'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => name = value,
            decoration: InputDecoration(hintText: "filename"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, name.trim()), child: Text('OK')),
          ],
        );
      },
    );

    if (fileName == null || fileName.isEmpty) return null;

    String fullpath = '${dir.path}/$fileName';
    final file = File(fullpath);

    // Overwrite confirmation
    if (await file.exists()) {
      final overwrite = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('File already exists'),
            content: Text('File "$fileName" already exists. Overwrite?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
            ],
          );
        },
      ) ??
          false;

      if (!overwrite) return null;
    }

    //await file.writeAsString(initialContent);
    return fullpath;
  }

  // Pick existing file from app folder
  static Future<String?> pickExistingFile() async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return null;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: dir.path,
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) return null;
    return result.files.single.path!;
  }

  // --- List all files in app folder and let user select ---
  static Future<String?> pickFileFromAppFolder(BuildContext context) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return null;

    final files = dir.listSync().whereType<File>().toList();

    if (files.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No files found'),
          content: Text('There are no files in the app folder.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
          ],
        ),
      );
      return null;
    }

    return showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a file'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final fileName = file.path;
                return ListTile(
                  title: Text(p.basename(fileName)),
                  onTap: () => Navigator.pop(context, fileName),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: Text('Cancel')),
          ],
        );
      },
    );
  }
}