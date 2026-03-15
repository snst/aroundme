import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FavoriteFileDialog extends StatelessWidget {
  final Function(String) onFileSelected; // Changed to File for better utility
  final Function(String) onNew;
  final Function(String) onSaveAs;
  final String title;

  const FavoriteFileDialog({
    super.key,
    required this.title,
    required this.onFileSelected,
    required this.onNew,
    required this.onSaveAs,
  });

  // Extracted the logic to a separate helper function
  Future<List<File>> _getFiles() async {
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      return dir.listSync().whereType<File>().toList();
    }
    return [];
  }

  static Future<String?> enterNewFileName(BuildContext context) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return null;
    if (!context.mounted) return null;

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
            //decoration: InputDecoration(hintText: "filename"),
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
      if (!context.mounted) return null;
      final overwrite =
          await showDialog<bool>(
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
    return fullpath;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: FutureBuilder<List<File>>(
          future: _getFiles(),
          builder: (context, snapshot) {
            // 1. Check for errors
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            // 2. Show loading spinner while waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final files = snapshot.data ?? [];

            // 3. Handle empty state
            if (files.isEmpty) {
              return const Center(child: Text("No files found."));
            }

            // 4. Render the list
            return ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final fileName = file.path.split('/').last;

                return ListTile(
                  title: Text(fileName),
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  onTap: () {
                    onFileSelected(file.path);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final filePath = await FavoriteFileDialog.enterNewFileName(context);
            if (filePath != null) {
              if (context.mounted) Navigator.pop(context);
              onNew(filePath);
            }
          },
          child: const Text('New'),
        ),
        TextButton(
          onPressed: () async {
            final filePath = await FavoriteFileDialog.enterNewFileName(context);
            if (filePath != null) {
              if (context.mounted) Navigator.pop(context);
              onSaveAs(filePath);
            }
          },
          child: const Text('Save as'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
