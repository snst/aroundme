// Copyright 2026 Stefan Schmidt
import 'package:aroundme/settings.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
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

  Future<void> _saveApiKey(BuildContext context) async {
    _apiKey = _apiKeyController.text;
    await Settings.setApiKey(_apiKey!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key Saved!')));
    }
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
            ElevatedButton(
              onPressed: () {
                _saveApiKey(context);
              },
              child: const Text('Save'),
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
