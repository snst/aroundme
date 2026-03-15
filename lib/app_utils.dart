// Copyright 2026 Stefan Schmidt
import 'dart:io';
import 'package:flutter/material.dart';

Future<bool> fileExists(String fullpath) async {
  final file = File(fullpath);
  return await file.exists();
}

Color getIconColor(bool isActive) {
  return isActive ? Colors.red.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6);
}
