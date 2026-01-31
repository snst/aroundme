import 'package:flutter/material.dart';

class QuickSearchFilters extends StatefulWidget {
  final Function(String) onSelected;

  const QuickSearchFilters({super.key, required this.onSelected});

  @override
  State<QuickSearchFilters> createState() => _QuickSearchFiltersState();
}

class _QuickSearchFiltersState extends State<QuickSearchFilters> {
  String? _selectedCategory;

  // Define your categories and their respective icons
  final List<Map<String, dynamic>> _categories = [
    {'label': 'Restaurants', 'icon': Icons.restaurant},
    {'label': 'Bars', 'icon': Icons.local_bar},
    {'label': 'Bakery', 'icon': Icons.bakery_dining},
    {'label': 'Shops', 'icon': Icons.shopping_bag},
    {'label': 'Gas', 'icon': Icons.local_gas_station},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Keeps the widget compact
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['label'];

          return ChoiceChip(
            label: Text(category['label']),
            avatar: Icon(
              category['icon'],
              size: 18,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            selected: isSelected,
            selectedColor: Colors.blue, // You could use your interpolated color here!
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? category['label'] : null;
              });
              if (selected) widget.onSelected(category['label']);
            },
          );
        },
      ),
    );
  }
}