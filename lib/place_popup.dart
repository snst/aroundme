// Copyright 2026 Stefan Schmidt
import 'package:aroundme/places.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

void showPlacePopup(BuildContext context, Place place) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min, //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Row
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text("${place.rating} (${place.userRatingCnt} reviews)", style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 24), // Actions Section
            Column(
              spacing: 8,
              children: [
                _buildActionButton(
                  icon: Icons.copy,
                  label: "Coordinates",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: "${place.location.latitude}, ${place.location.longitude}"));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location copied!")));
                  },
                ),
                _buildActionButton(
                  icon: Icons.directions,
                  label: "Navigation",
                  onTap: () => launchURL(place.gmDirections),
                ),

                _buildActionButton(icon: Icons.star, label: "Reviews", onTap: () => launchURL(place.gmReviews)),
                _buildActionButton(icon: Icons.info, label: "Place", onTap: () => launchURL(place.gmPlace)),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// Helper to build small action chips/buttons
Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
  return ActionChip(avatar: Icon(icon, size: 16), label: Text(label), onPressed: onTap);
}
