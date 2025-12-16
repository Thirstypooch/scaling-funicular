import 'package:flutter/material.dart';

enum TabType {
  sku,
  categoria,
  subcategoria,
  familia,
}

extension TabTypeExtension on TabType {
  String get label {
    switch (this) {
      case TabType.sku:
        return 'SKU';
      case TabType.categoria:
        return 'Categoría';
      case TabType.subcategoria:
        return 'Subcat';
      case TabType.familia:
        return 'Familia';
    }
  }

  String get groupLabel {
    switch (this) {
      case TabType.sku:
        return 'SKU';
      case TabType.categoria:
        return 'categoría';
      case TabType.subcategoria:
        return 'subcategoría';
      case TabType.familia:
        return 'familia';
    }
  }

  IconData get icon {
    switch (this) {
      case TabType.sku:
        return Icons.inventory_2_rounded;
      case TabType.categoria:
        return Icons.category_rounded;
      case TabType.subcategoria:
        return Icons.auto_graph_rounded;
      case TabType.familia:
        return Icons.groups_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case TabType.sku:
        return const Color(0xFFD97706); // Amber/Orange
      case TabType.categoria:
        return const Color(0xFF7C3AED); // Purple
      case TabType.subcategoria:
        return const Color(0xFFEC4899); // Pink
      case TabType.familia:
        return const Color(0xFF0EA5E9); // Sky blue
    }
  }
}
