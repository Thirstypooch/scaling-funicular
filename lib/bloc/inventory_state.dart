import 'package:equatable/equatable.dart';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import '../repositories/inventory_repository.dart';

enum InventoryStatus {
  initial,
  loading,
  loaded,
  streaming,
  error,
}

class InventoryState extends Equatable {
  final InventoryStatus status;
  final TabType selectedTab;
  final List<InventoryItem> items;
  final InventorySummary? summary;
  final String searchQuery;
  final Map<String, String> filters;
  final FilterOptions filterOptions;
  final String? errorMessage;
  final String inventoryDate;
  final bool isStreaming;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.selectedTab = TabType.sku,
    this.items = const [],
    this.summary,
    this.searchQuery = '',
    this.filters = const {
      'Categoría': 'Todos',
      'Subcategoría': 'Todos',
      'Familia': 'Todos',
      'Subfamilia': 'Todos',
    },
    this.filterOptions = FilterOptions.defaults,
    this.errorMessage,
    this.inventoryDate = '',
    this.isStreaming = false,
  });

  /// Initial state
  factory InventoryState.initial() => const InventoryState();

  /// Loading state
  InventoryState loading() => copyWith(
        status: InventoryStatus.loading,
        errorMessage: null,
      );

  /// Loaded state with items
  InventoryState loaded({
    required List<InventoryItem> items,
    required String date,
    bool streaming = false,
  }) {
    return copyWith(
      status: streaming ? InventoryStatus.streaming : InventoryStatus.loaded,
      items: items,
      summary: InventorySummary.fromItems(items, date),
      inventoryDate: date,
      errorMessage: null,
      isStreaming: streaming,
    );
  }

  /// Error state
  InventoryState error(String message) => copyWith(
        status: InventoryStatus.error,
        errorMessage: message,
        isStreaming: false,
      );

  /// Copy with method for immutable state updates
  InventoryState copyWith({
    InventoryStatus? status,
    TabType? selectedTab,
    List<InventoryItem>? items,
    InventorySummary? summary,
    String? searchQuery,
    Map<String, String>? filters,
    FilterOptions? filterOptions,
    String? errorMessage,
    String? inventoryDate,
    bool? isStreaming,
  }) {
    return InventoryState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      filterOptions: filterOptions ?? this.filterOptions,
      errorMessage: errorMessage,
      inventoryDate: inventoryDate ?? this.inventoryDate,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        items,
        summary,
        searchQuery,
        filters,
        filterOptions,
        errorMessage,
        inventoryDate,
        isStreaming,
      ];
}
