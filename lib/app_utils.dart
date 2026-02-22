// Copyright 2026 Stefan Schmidt
import 'dart:io';

Future<bool> fileExists(String fullpath) async {
  final file = File(fullpath);
  return await file.exists();
}
