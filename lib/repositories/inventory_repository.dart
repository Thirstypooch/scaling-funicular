import '../models/inventory_item.dart';
import '../models/tab_type.dart';

/// Data class for inventory summary metrics
class InventorySummary {
  final int totalSellOut;
  final int totalInventory;
  final int totalSellIn;
  final int totalRegistros;
  final int totalSkus;
  final String date;

  const InventorySummary({
    required this.totalSellOut,
    required this.totalInventory,
    required this.totalSellIn,
    required this.totalRegistros,
    required this.totalSkus,
    required this.date,
  });

  factory InventorySummary.fromItems(List<InventoryItem> items, String date) {
    return InventorySummary(
      totalSellOut: items.fold(0, (sum, item) => sum + item.sellOut),
      totalInventory: items.fold(0, (sum, item) => sum + item.inventory),
      totalSellIn: items.fold(0, (sum, item) => sum + item.sellIn),
      totalRegistros: items.fold(0, (sum, item) => sum + item.registros),
      totalSkus: items.fold(0, (sum, item) => sum + item.skus),
      date: date,
    );
  }
}

/// Data class for filter options
class FilterOptions {
  final List<String> categorias;
  final List<String> subcategorias;
  final List<String> familias;
  final List<String> subfamilias;

  const FilterOptions({
    required this.categorias,
    required this.subcategorias,
    required this.familias,
    required this.subfamilias,
  });

  static const FilterOptions defaults = FilterOptions(
    categorias: ['Todos', 'Gomas & Caramelos', 'Galletas', 'Bebidas & Postres', 'MISCELANEOS'],
    subcategorias: ['Todos', 'Gomas', 'Galletas', 'Bebidas', 'Miscelaneos'],
    familias: ['Todos', 'Trident', 'Oreo', 'Ritz', 'Clight', 'MISCELANEOS'],
    subfamilias: ['Todos'],
  );
}

/// Abstract repository interface for inventory data
abstract class InventoryRepository {
  /// Stream of inventory items for real-time updates
  Stream<List<InventoryItem>> watchItems(TabType tabType);

  /// Get items once (for non-streaming scenarios)
  Future<List<InventoryItem>> getItems(TabType tabType);

  /// Get filtered items
  Future<List<InventoryItem>> getFilteredItems({
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  });

  /// Stream of filtered items for real-time updates
  Stream<List<InventoryItem>> watchFilteredItems({
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  });

  /// Get filter options
  Future<FilterOptions> getFilterOptions();

  /// Get current date string for inventory
  String get inventoryDate;
}
