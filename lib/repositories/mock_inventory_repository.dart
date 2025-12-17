import 'dart:async';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import 'inventory_repository.dart';

/// Mock implementation of InventoryRepository using hardcoded data
class MockInventoryRepository implements InventoryRepository {
  // Simulate periodic data updates (every 30 seconds)
  static const Duration _updateInterval = Duration(seconds: 30);

  @override
  String get inventoryDate => MockData.inventoryDate;

  @override
  Future<List<InventoryItem>> getItems(TabType tabType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.getItemsForTab(tabType);
  }

  @override
  Stream<List<InventoryItem>> watchItems(TabType tabType) async* {
    // Emit initial data
    yield MockData.getItemsForTab(tabType);

    // Then emit updates periodically (simulating real-time data)
    await for (final _ in Stream.periodic(_updateInterval)) {
      yield MockData.getItemsForTab(tabType);
    }
  }

  @override
  Future<List<InventoryItem>> getFilteredItems({
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _applyFilters(
      items: MockData.getItemsForTab(tabType),
      tabType: tabType,
      searchQuery: searchQuery,
      filters: filters,
    );
  }

  @override
  Stream<List<InventoryItem>> watchFilteredItems({
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  }) async* {
    // Emit initial filtered data
    yield _applyFilters(
      items: MockData.getItemsForTab(tabType),
      tabType: tabType,
      searchQuery: searchQuery,
      filters: filters,
    );

    // Then emit updates periodically
    await for (final _ in Stream.periodic(_updateInterval)) {
      yield _applyFilters(
        items: MockData.getItemsForTab(tabType),
        tabType: tabType,
        searchQuery: searchQuery,
        filters: filters,
      );
    }
  }

  @override
  Future<FilterOptions> getFilterOptions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return FilterOptions.defaults;
  }

  @override
  Future<ChunkedResult<InventoryItem>> getItemsChunked({
    required TabType tabType,
    required int offset,
    required int limit,
    String? searchQuery,
    Map<String, String>? filters,
  }) async {
    // Simulate network delay (longer for subsequent chunks to feel realistic)
    await Future.delayed(Duration(milliseconds: offset == 0 ? 300 : 500));

    // Get all filtered items first
    final allItems = _applyFilters(
      items: MockData.getItemsForTab(tabType),
      tabType: tabType,
      searchQuery: searchQuery,
      filters: filters,
    );

    final totalCount = allItems.length;

    // Apply offset and limit
    final startIndex = offset.clamp(0, totalCount);
    final endIndex = (offset + limit).clamp(0, totalCount);
    final chunk = allItems.sublist(startIndex, endIndex);

    final hasMore = endIndex < totalCount;

    return ChunkedResult(
      items: chunk,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }

  @override
  Stream<ChunkedResult<InventoryItem>> watchItemsChunked({
    required TabType tabType,
    required int offset,
    required int limit,
    String? searchQuery,
    Map<String, String>? filters,
  }) async* {
    // Emit initial chunk
    yield await getItemsChunked(
      tabType: tabType,
      offset: offset,
      limit: limit,
      searchQuery: searchQuery,
      filters: filters,
    );

    // Then emit updates periodically (simulating real-time data)
    await for (final _ in Stream.periodic(_updateInterval)) {
      yield await getItemsChunked(
        tabType: tabType,
        offset: offset,
        limit: limit,
        searchQuery: searchQuery,
        filters: filters,
      );
    }
  }

  List<InventoryItem> _applyFilters({
    required List<InventoryItem> items,
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  }) {
    var result = List<InventoryItem>.from(items);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((item) {
        final title = item.getDisplayTitle(tabType).toLowerCase();
        final id = item.id.toLowerCase();
        return title.contains(query) || id.contains(query);
      }).toList();
    }

    // Apply category filters (only for SKU tab)
    if (filters != null && tabType == TabType.sku) {
      final categoria = filters['Categoría'];
      if (categoria != null && categoria != 'Todos') {
        result = result.where((item) => item.categoria == categoria).toList();
      }

      final subcategoria = filters['Subcategoría'];
      if (subcategoria != null && subcategoria != 'Todos') {
        result = result.where((item) => item.subcategoria == subcategoria).toList();
      }

      final familia = filters['Familia'];
      if (familia != null && familia != 'Todos') {
        result = result.where((item) => item.familia == familia).toList();
      }
    }

    return result;
  }
}
