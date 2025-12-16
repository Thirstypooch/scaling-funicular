import 'dart:async';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import 'inventory_repository.dart';

/// API implementation of InventoryRepository
///
/// This is a template for connecting to a real API.
/// Replace the TODO comments with actual API calls.
class ApiInventoryRepository implements InventoryRepository {
  final String baseUrl;
  final Duration pollInterval;

  // Stream controllers for real-time updates
  final Map<TabType, StreamController<List<InventoryItem>>> _itemControllers = {};
  final Map<String, StreamController<List<InventoryItem>>> _filteredControllers = {};
  Timer? _pollTimer;

  ApiInventoryRepository({
    required this.baseUrl,
    this.pollInterval = const Duration(seconds: 10),
  });

  @override
  String get inventoryDate {
    // TODO: Get from API or use current date
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<InventoryItem>> getItems(TabType tabType) async {
    // TODO: Replace with actual API call
    // Example:
    // final response = await http.get(Uri.parse('$baseUrl/inventory/${tabType.name}'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> json = jsonDecode(response.body);
    //   return json.map((e) => InventoryItem.fromJson(e)).toList();
    // }
    // throw Exception('Failed to load inventory');

    throw UnimplementedError('API not implemented. Use MockInventoryRepository for development.');
  }

  @override
  Stream<List<InventoryItem>> watchItems(TabType tabType) {
    // Create controller if not exists
    _itemControllers[tabType] ??= StreamController<List<InventoryItem>>.broadcast();

    // Start polling if not already started
    _startPolling();

    // Initial fetch
    _fetchAndEmit(tabType);

    return _itemControllers[tabType]!.stream;
  }

  @override
  Future<List<InventoryItem>> getFilteredItems({
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  }) async {
    // TODO: Replace with actual API call with query parameters
    // Example:
    // final queryParams = {
    //   'tab': tabType.name,
    //   if (searchQuery != null) 'search': searchQuery,
    //   ...?filters,
    // };
    // final uri = Uri.parse('$baseUrl/inventory/filtered').replace(queryParameters: queryParams);
    // final response = await http.get(uri);
    // ...

    throw UnimplementedError('API not implemented. Use MockInventoryRepository for development.');
  }

  @override
  Stream<List<InventoryItem>> watchFilteredItems({
    required TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
  }) {
    final key = _getFilterKey(tabType, searchQuery, filters);

    _filteredControllers[key] ??= StreamController<List<InventoryItem>>.broadcast(
      onCancel: () {
        _filteredControllers[key]?.close();
        _filteredControllers.remove(key);
      },
    );

    // Start polling
    _startFilteredPolling(tabType, searchQuery, filters, key);

    return _filteredControllers[key]!.stream;
  }

  @override
  Future<FilterOptions> getFilterOptions() async {
    // TODO: Fetch filter options from API
    // Example:
    // final response = await http.get(Uri.parse('$baseUrl/filters'));
    // if (response.statusCode == 200) {
    //   return FilterOptions.fromJson(jsonDecode(response.body));
    // }

    // Return defaults for now
    return FilterOptions.defaults;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) {
      for (final tabType in _itemControllers.keys) {
        _fetchAndEmit(tabType);
      }
    });
  }

  Future<void> _fetchAndEmit(TabType tabType) async {
    try {
      final items = await getItems(tabType);
      _itemControllers[tabType]?.add(items);
    } catch (e) {
      _itemControllers[tabType]?.addError(e);
    }
  }

  void _startFilteredPolling(
    TabType tabType,
    String? searchQuery,
    Map<String, String>? filters,
    String key,
  ) {
    // Initial fetch
    getFilteredItems(
      tabType: tabType,
      searchQuery: searchQuery,
      filters: filters,
    ).then((items) {
      _filteredControllers[key]?.add(items);
    }).catchError((e) {
      _filteredControllers[key]?.addError(e);
    });
  }

  String _getFilterKey(TabType tabType, String? searchQuery, Map<String, String>? filters) {
    return '${tabType.name}_${searchQuery ?? ''}_${filters?.toString() ?? ''}';
  }

  /// Call this to clean up resources
  void dispose() {
    _pollTimer?.cancel();
    for (final controller in _itemControllers.values) {
      controller.close();
    }
    for (final controller in _filteredControllers.values) {
      controller.close();
    }
    _itemControllers.clear();
    _filteredControllers.clear();
  }
}
