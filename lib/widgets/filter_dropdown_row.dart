import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'filter_dropdown.dart';

class FilterDropdownRow extends StatelessWidget {
  final Map<String, String> selectedFilters;
  final ValueChanged<MapEntry<String, String>>? onFilterChanged;

  const FilterDropdownRow({
    super.key,
    required this.selectedFilters,
    this.onFilterChanged,
  });

  static const List<String> filterLabels = [
    'Categoría',
    'Subcategoría',
    'Familia',
    'Subfamilia',
  ];

  static const Map<String, List<String>> filterOptions = {
    'Categoría': ['Todos', 'Gomas & Caramelos', 'Galletas', 'Bebidas & Postres', 'MISCELANEOS'],
    'Subcategoría': ['Todos', 'Gomas', 'Galletas', 'Bebidas', 'Miscelaneos'],
    'Familia': ['Todos', 'Trident', 'Oreo', 'Ritz', 'Clight', 'MISCELANEOS'],
    'Subfamilia': ['Todos'],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterLabels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : AppTheme.spacingS,
            ),
            child: FilterDropdown(
              label: label,
              value: selectedFilters[label] ?? 'Todos',
              options: filterOptions[label] ?? ['Todos'],
              onChanged: (value) {
                onFilterChanged?.call(MapEntry(label, value));
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
