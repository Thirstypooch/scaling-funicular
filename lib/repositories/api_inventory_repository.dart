import 'dart:async';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import '../services/api_service.dart';
import 'inventory_repository.dart';

/// API-based implementation of InventoryRepository
/// Uses real API for inventory data with calculated KPIs from historical data
class ApiInventoryRepository implements InventoryRepository {
  final ApiService _apiService;

  // Cache for converted items
  List<InventoryItem>? _cachedItems;
  DateTime? _cacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Simulate periodic data updates
  static const Duration _updateInterval = Duration(seconds: 30);

  // Cached KPI data
  _KpiData? _cachedKpiData;

  ApiInventoryRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  String get inventoryDate {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get _isCacheValid =>
      _cachedItems != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheExpiry;

  Future<List<InventoryItem>> _fetchAndConvertItems() async {
    if (_isCacheValid) {
      return _cachedItems!;
    }

    try {
      final response = await _apiService.getInventoryCatalog();
      final allApiItems = response.data;

      // Calculate KPIs from historical data
      _cachedKpiData = _calculateKpis(allApiItems);

      // Convert items (filter to today's or most recent date)
      final todayItems = _filterToCurrentDate(allApiItems);
      final items = todayItems.asMap().entries.map((entry) {
        final index = entry.key;
        final apiItem = entry.value;
        return _convertToInventoryItem(apiItem, index, _cachedKpiData!);
      }).toList();

      _cachedItems = items;
      _cacheTime = DateTime.now();

      return items;
    } catch (e) {
      // If we have cached data, return it even if expired
      if (_cachedItems != null) {
        return _cachedItems!;
      }
      rethrow;
    }
  }

  /// Calculate KPIs by comparing inventory across dates
  _KpiData _calculateKpis(List<InventoryApiItem> allItems) {
    // Group items by date
    final Map<String, List<InventoryApiItem>> byDate = {};
    for (final item in allItems) {
      byDate.putIfAbsent(item.fechaRegistro, () => []).add(item);
    }

    // Sort dates to get today and yesterday
    final sortedDates = byDate.keys.toList()..sort();

    if (sortedDates.isEmpty) {
      return _KpiData.empty();
    }

    final currentDate = sortedDates.last;
    final currentItems = byDate[currentDate]!;

    // Calculate current totals
    final currentInventory = currentItems.fold<int>(
      0, (sum, item) => sum + item.existenciaUnidades + item.existenciaCajas,
    );
    final currentRegistros = currentItems.length;
    final currentSkus = currentItems.map((i) => '${i.categoria}_${i.familia}').toSet().length;

    // Find previous date for comparison
    int previousInventory = 0;
    String? previousDate;

    if (sortedDates.length > 1) {
      previousDate = sortedDates[sortedDates.length - 2];
      final previousItems = byDate[previousDate]!;
      previousInventory = previousItems.fold<int>(
        0, (sum, item) => sum + item.existenciaUnidades + item.existenciaCajas,
      );
    }

    // Calculate SellIn and SellOut based on inventory delta
    final delta = currentInventory - previousInventory;
    int sellIn = 0;
    int sellOut = 0;

    if (delta > 0) {
      // Inventory increased = SellIn (restocking)
      sellIn = delta;
    } else if (delta < 0) {
      // Inventory decreased = SellOut (sales)
      sellOut = delta.abs();
    }

    // Calculate per-item deltas for more granular KPIs
    final Map<String, int> itemDeltas = {};
    if (previousDate != null) {
      final previousItems = byDate[previousDate]!;
      final previousMap = <String, int>{};
      for (final item in previousItems) {
        final key = '${item.categoria}_${item.familia}_${item.subfamilia}';
        previousMap[key] = (previousMap[key] ?? 0) + item.existenciaUnidades;
      }

      for (final item in currentItems) {
        final key = '${item.categoria}_${item.familia}_${item.subfamilia}';
        final prev = previousMap[key] ?? 0;
        final current = item.existenciaUnidades;
        itemDeltas[key] = current - prev;
      }
    }

    return _KpiData(
      totalInventory: currentInventory,
      totalSellIn: sellIn,
      totalSellOut: sellOut,
      totalRegistros: currentRegistros,
      totalSkus: currentSkus,
      currentDate: currentDate,
      previousDate: previousDate,
      itemDeltas: itemDeltas,
    );
  }

  /// Filter to current date items (or most recent if no today's data)
  List<InventoryApiItem> _filterToCurrentDate(List<InventoryApiItem> items) {
    if (items.isEmpty) return [];

    // Get all dates and find the most recent
    final dates = items.map((i) => i.fechaRegistro).toSet().toList()..sort();
    final mostRecentDate = dates.last;

    return items.where((i) => i.fechaRegistro == mostRecentDate).toList();
  }

  InventoryItem _convertToInventoryItem(
    InventoryApiItem apiItem,
    int index,
    _KpiData kpiData,
  ) {
    final baseInventory = apiItem.existenciaUnidades + apiItem.existenciaCajas;

    // Get item-specific delta for SellIn/SellOut
    final key = '${apiItem.categoria}_${apiItem.familia}_${apiItem.subfamilia}';
    final itemDelta = kpiData.itemDeltas[key] ?? 0;

    final sellIn = itemDelta > 0 ? itemDelta : 0;
    final sellOut = itemDelta < 0 ? itemDelta.abs() : 0;
    final initialInventory = baseInventory - sellIn + sellOut;

    return InventoryItem(
      id: apiItem.id,
      name: apiItem.producto ?? _generateProductName(apiItem),
      categoria: apiItem.categoria.isNotEmpty ? apiItem.categoria : null,
      subcategoria: apiItem.subcategoria.isNotEmpty ? apiItem.subcategoria : null,
      familia: apiItem.familia.isNotEmpty ? apiItem.familia : null,
      subfamilia: apiItem.subfamilia.isNotEmpty ? apiItem.subfamilia : null,
      registros: 1,
      skus: 1,
      inventory: baseInventory,
      sellIn: sellIn,
      sellOut: sellOut,
      initialInventory: initialInventory,
      position: index + 1,
      timestamp: _formatTimestamp(apiItem.fechaRegistro),
      hasSales: sellOut > 0,
    );
  }

  String _generateProductName(InventoryApiItem apiItem) {
    if (apiItem.familia.isNotEmpty) {
      return apiItem.familia;
    } else if (apiItem.categoria.isNotEmpty) {
      return apiItem.categoria;
    }
    return 'Producto ${apiItem.id}';
  }

  String _formatTimestamp(String dateStr) {
    try {
      final now = DateTime.now();
      final hour = now.hour;
      final minute = now.minute;
      final period = hour >= 12 ? 'p' : 'a';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period. m.';
    } catch (_) {}
    return '12:00 p. m.';
  }

  List<InventoryItem> _groupItemsByTab(List<InventoryItem> items, TabType tabType) {
    switch (tabType) {
      case TabType.sku:
        return items;

      case TabType.categoria:
        return _groupBy(items, (item) => item.categoria ?? 'Sin categoría')
            .entries
            .map((entry) => _createGroupedItem(
                  entry.key,
                  entry.value,
                  TabType.categoria,
                ))
            .toList();

      case TabType.subcategoria:
        return _groupBy(items, (item) => item.subcategoria ?? 'Sin subcategoría')
            .entries
            .map((entry) => _createGroupedItem(
                  entry.key,
                  entry.value,
                  TabType.subcategoria,
                ))
            .toList();

      case TabType.familia:
        return _groupBy(items, (item) => item.familia ?? 'Sin familia')
            .entries
            .map((entry) => _createGroupedItem(
                  entry.key,
                  entry.value,
                  TabType.familia,
                ))
            .toList();
    }
  }

  Map<String, List<InventoryItem>> _groupBy(
    List<InventoryItem> items,
    String Function(InventoryItem) keyExtractor,
  ) {
    final Map<String, List<InventoryItem>> grouped = {};
    for (final item in items) {
      final key = keyExtractor(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  InventoryItem _createGroupedItem(
    String groupName,
    List<InventoryItem> items,
    TabType tabType,
  ) {
    final totalInventory = items.fold<int>(0, (sum, item) => sum + item.inventory);
    final totalSellIn = items.fold<int>(0, (sum, item) => sum + item.sellIn);
    final totalSellOut = items.fold<int>(0, (sum, item) => sum + item.sellOut);
    final totalInitial = items.fold<int>(0, (sum, item) => sum + item.initialInventory);
    final totalRegistros = items.fold<int>(0, (sum, item) => sum + item.registros);

    return InventoryItem(
      id: 'group_${tabType.name}_${groupName.hashCode}',
      name: groupName,
      categoria: tabType == TabType.categoria ? groupName : null,
      subcategoria: tabType == TabType.subcategoria ? groupName : null,
      familia: tabType == TabType.familia ? groupName : null,
      registros: totalRegistros,
      skus: items.length,
      inventory: totalInventory,
      sellIn: totalSellIn,
      sellOut: totalSellOut,
      initialInventory: totalInitial,
      position: 0, // Will be set when sorting
      timestamp: items.isNotEmpty ? items.first.timestamp : '12:00 p. m.',
      hasSales: totalSellOut > 0,
    );
  }

  @override
  Future<List<InventoryItem>> getItems(TabType tabType) async {
    final allItems = await _fetchAndConvertItems();
    final groupedItems = _groupItemsByTab(allItems, tabType);

    // Assign positions
    final result = <InventoryItem>[];
    for (int i = 0; i < groupedItems.length; i++) {
      final item = groupedItems[i];
      result.add(InventoryItem(
        id: item.id,
        name: item.name,
        categoria: item.categoria,
        subcategoria: item.subcategoria,
        familia: item.familia,
        subfamilia: item.subfamilia,
        registros: item.registros,
        skus: item.skus,
        inventory: item.inventory,
        sellIn: item.sellIn,
        sellOut: item.sellOut,
        initialInventory: item.initialInventory,
        position: i + 1,
        timestamp: item.timestamp,
        hasSales: item.hasSales,
      ));
    }

    return result;
  }

  @override
  Stream<List<InventoryItem>> watchItems(TabType tabType) async* {
    yield await getItems(tabType);

    await for (final _ in Stream.periodic(_updateInterval)) {
      _cachedItems = null; // Invalidate cache to get fresh data
      yield await getItems(tabType);
    }
  }

  @override
  Future<List<InventoryItem>> getFilteredItems({
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  }) async {
    final items = await getItems(tabType);
    return _applyFilters(
      items: items,
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
    yield await getFilteredItems(
      tabType: tabType,
      searchQuery: searchQuery,
      filters: filters,
    );

    await for (final _ in Stream.periodic(_updateInterval)) {
      _cachedItems = null;
      yield await getFilteredItems(
        tabType: tabType,
        searchQuery: searchQuery,
        filters: filters,
      );
    }
  }

  @override
  Future<FilterOptions> getFilterOptions() async {
    final items = await _fetchAndConvertItems();

    final categorias = <String>{'Todos'};
    final subcategorias = <String>{'Todos'};
    final familias = <String>{'Todos'};
    final subfamilias = <String>{'Todos'};

    for (final item in items) {
      if (item.categoria != null && item.categoria!.isNotEmpty) {
        categorias.add(item.categoria!);
      }
      if (item.subcategoria != null && item.subcategoria!.isNotEmpty) {
        subcategorias.add(item.subcategoria!);
      }
      if (item.familia != null && item.familia!.isNotEmpty) {
        familias.add(item.familia!);
      }
      if (item.subfamilia != null && item.subfamilia!.isNotEmpty) {
        subfamilias.add(item.subfamilia!);
      }
    }

    return FilterOptions(
      categorias: categorias.toList()..sort(),
      subcategorias: subcategorias.toList()..sort(),
      familias: familias.toList()..sort(),
      subfamilias: subfamilias.toList()..sort(),
    );
  }

  @override
  Future<ChunkedResult<InventoryItem>> getItemsChunked({
    required TabType tabType,
    required int offset,
    required int limit,
    String? searchQuery,
    Map<String, String>? filters,
  }) async {
    final allItems = await getFilteredItems(
      tabType: tabType,
      searchQuery: searchQuery,
      filters: filters,
    );

    final totalCount = allItems.length;
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
    yield await getItemsChunked(
      tabType: tabType,
      offset: offset,
      limit: limit,
      searchQuery: searchQuery,
      filters: filters,
    );

    await for (final _ in Stream.periodic(_updateInterval)) {
      _cachedItems = null;
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

        if (tabType != TabType.sku) {
          final name = item.name.toLowerCase();
          final categoria = (item.categoria ?? '').toLowerCase();
          final subcategoria = (item.subcategoria ?? '').toLowerCase();
          final familia = (item.familia ?? '').toLowerCase();

          return title.contains(query) ||
              id.contains(query) ||
              name.contains(query) ||
              categoria.contains(query) ||
              subcategoria.contains(query) ||
              familia.contains(query);
        }

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

  void dispose() {
    _apiService.dispose();
  }
}

/// Helper class to hold calculated KPI data
class _KpiData {
  final int totalInventory;
  final int totalSellIn;
  final int totalSellOut;
  final int totalRegistros;
  final int totalSkus;
  final String currentDate;
  final String? previousDate;
  final Map<String, int> itemDeltas;

  const _KpiData({
    required this.totalInventory,
    required this.totalSellIn,
    required this.totalSellOut,
    required this.totalRegistros,
    required this.totalSkus,
    required this.currentDate,
    this.previousDate,
    required this.itemDeltas,
  });

  factory _KpiData.empty() => const _KpiData(
        totalInventory: 0,
        totalSellIn: 0,
        totalSellOut: 0,
        totalRegistros: 0,
        totalSkus: 0,
        currentDate: '',
        previousDate: null,
        itemDeltas: {},
      );
}
