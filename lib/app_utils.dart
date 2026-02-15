import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';

Future<Map<String, String>?> showSaveAsDialog(BuildContext context) async {
  TextEditingController nameController = TextEditingController(text: "new_file");
  TextEditingController pathController = TextEditingController(text: "No folder selected");
  String? selectedDirectory;

  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) {
      // Use StateLogger or StatefulBuilder to update the dialog UI when a folder is picked
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Save File As'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. File Name Input
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "File Name",
                  suffixText: ".txt",
                ),
              ),
              const SizedBox(height: 20),

              // 2. Directory Selection Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDirectory ?? "Pick a destination folder...",
                      style: TextStyle(
                          fontSize: 12,
                          color: selectedDirectory == null ? Colors.red : Colors.grey[700]
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      /*
                      String? result = await FilePicker.platform.getDirectoryPath();
                      if (result != null) {
                        setState(() {
                          selectedDirectory = result;
                        });
                      }*/
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              // Disable button if no directory is picked
              onPressed: selectedDirectory == null
                  ? null
                  : () => Navigator.pop(context, {
                'name': nameController.text,
                'path': selectedDirectory!,
              }),
              child: const Text('SAVE'),
            ),
          ],
        );
      });
    },
  );
}