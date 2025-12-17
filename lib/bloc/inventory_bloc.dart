import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;
  StreamSubscription<ChunkedResult<InventoryItem>>? _itemsSubscription;

  InventoryBloc({required this.repository}) : super(InventoryState.initial()) {
    on<LoadInventory>(_onLoadInventory);
    on<LoadMoreItems>(_onLoadMoreItems);
    on<RefreshInventory>(_onRefreshInventory);
    on<SubscribeToInventory>(_onSubscribeToInventory);
    on<UnsubscribeFromInventory>(_onUnsubscribeFromInventory);
    on<ChangeTab>(_onChangeTab);
    on<UpdateSearch>(_onUpdateSearch);
    on<UpdateFilter>(_onUpdateFilter);
    on<ResetFilters>(_onResetFilters);
    on<ItemsUpdated>(_onItemsUpdated);
    on<InventoryError>(_onInventoryError);
  }

  /// Load initial inventory data (first chunk)
  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.loading().copyWith(
      currentOffset: 0,
      hasMore: true,
      isLoadingMore: false,
    ));

    try {
      final result = await repository.getItemsChunked(
        tabType: state.selectedTab,
        offset: 0,
        limit: InventoryState.initialChunkSize,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        filters: state.filters,
      );

      emit(state.copyWith(
        status: InventoryStatus.loaded,
        items: result.items,
        hasMore: result.hasMore,
        totalCount: result.totalCount,
        currentOffset: result.items.length,
        summary: InventorySummary.fromItems(result.items, repository.inventoryDate),
        inventoryDate: repository.inventoryDate,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.error(e.toString()));
    }
  }

  /// Load more items for infinite scrolling
  Future<void> _onLoadMoreItems(
    LoadMoreItems event,
    Emitter<InventoryState> emit,
  ) async {
    // Don't load more if already loading or no more items
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await repository.getItemsChunked(
        tabType: state.selectedTab,
        offset: state.currentOffset,
        limit: InventoryState.loadMoreChunkSize,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        filters: state.filters,
      );

      // Append new items to existing list
      final updatedItems = [...state.items, ...result.items];

      emit(state.copyWith(
        items: updatedItems,
        hasMore: result.hasMore,
        totalCount: result.totalCount,
        currentOffset: state.currentOffset + result.items.length,
        isLoadingMore: false,
        summary: InventorySummary.fromItems(updatedItems, repository.inventoryDate),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Refresh inventory data (pull-to-refresh)
  Future<void> _onRefreshInventory(
    RefreshInventory event,
    Emitter<InventoryState> emit,
  ) async {
    // Don't refresh if already refreshing
    if (state.isRefreshing) return;

    emit(state.copyWith(isRefreshing: true));

    try {
      // Simulate a slight delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 300));

      final result = await repository.getItemsChunked(
        tabType: state.selectedTab,
        offset: 0,
        limit: InventoryState.initialChunkSize,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        filters: state.filters,
      );

      emit(state.copyWith(
        status: InventoryStatus.loaded,
        items: result.items,
        hasMore: result.hasMore,
        totalCount: result.totalCount,
        currentOffset: result.items.length,
        summary: InventorySummary.fromItems(result.items, repository.inventoryDate),
        inventoryDate: repository.inventoryDate,
        isRefreshing: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Subscribe to real-time inventory updates (with chunking)
  Future<void> _onSubscribeToInventory(
    SubscribeToInventory event,
    Emitter<InventoryState> emit,
  ) async {
    await _itemsSubscription?.cancel();

    emit(state.loading().copyWith(
      currentOffset: 0,
      hasMore: true,
    ));

    _itemsSubscription = repository
        .watchItemsChunked(
          tabType: state.selectedTab,
          offset: 0,
          limit: InventoryState.initialChunkSize,
          searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
          filters: state.filters,
        )
        .listen(
          (result) => add(ItemsUpdated(result.items)),
          onError: (error) => add(InventoryError(error.toString())),
        );
  }

  /// Unsubscribe from real-time updates
  Future<void> _onUnsubscribeFromInventory(
    UnsubscribeFromInventory event,
    Emitter<InventoryState> emit,
  ) async {
    await _itemsSubscription?.cancel();
    _itemsSubscription = null;
    emit(state.copyWith(isStreaming: false));
  }

  /// Change the selected tab (reset pagination)
  Future<void> _onChangeTab(
    ChangeTab event,
    Emitter<InventoryState> emit,
  ) async {
    if (event.tabType == state.selectedTab) return;

    emit(state.copyWith(
      selectedTab: event.tabType,
      status: InventoryStatus.loading,
      items: [],
      currentOffset: 0,
      hasMore: true,
    ));

    // Re-subscribe or reload based on current mode
    if (state.isStreaming || _itemsSubscription != null) {
      await _itemsSubscription?.cancel();
      _itemsSubscription = repository
          .watchItemsChunked(
            tabType: event.tabType,
            offset: 0,
            limit: InventoryState.initialChunkSize,
            searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
            filters: state.filters,
          )
          .listen(
            (result) => add(ItemsUpdated(result.items)),
            onError: (error) => add(InventoryError(error.toString())),
          );
    } else {
      try {
        final result = await repository.getItemsChunked(
          tabType: event.tabType,
          offset: 0,
          limit: InventoryState.initialChunkSize,
          searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
          filters: state.filters,
        );

        emit(state.copyWith(
          selectedTab: event.tabType,
          status: InventoryStatus.loaded,
          items: result.items,
          hasMore: result.hasMore,
          totalCount: result.totalCount,
          currentOffset: result.items.length,
          summary: InventorySummary.fromItems(result.items, repository.inventoryDate),
          inventoryDate: repository.inventoryDate,
        ));
      } catch (e) {
        emit(state.copyWith(selectedTab: event.tabType).error(e.toString()));
      }
    }
  }

  /// Update search query (reset pagination)
  Future<void> _onUpdateSearch(
    UpdateSearch event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      currentOffset: 0,
      hasMore: true,
    ));

    await _refreshData(emit);
  }

  /// Update a filter value (reset pagination)
  Future<void> _onUpdateFilter(
    UpdateFilter event,
    Emitter<InventoryState> emit,
  ) async {
    final newFilters = Map<String, String>.from(state.filters);
    newFilters[event.filterKey] = event.filterValue;

    emit(state.copyWith(
      filters: newFilters,
      currentOffset: 0,
      hasMore: true,
    ));
    await _refreshData(emit);
  }

  /// Reset all filters (reset pagination)
  Future<void> _onResetFilters(
    ResetFilters event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(
      filters: const {
        'Categoría': 'Todos',
        'Subcategoría': 'Todos',
        'Familia': 'Todos',
        'Subfamilia': 'Todos',
      },
      searchQuery: '',
      currentOffset: 0,
      hasMore: true,
    ));
    await _refreshData(emit);
  }

  /// Handle items updated from stream
  void _onItemsUpdated(
    ItemsUpdated event,
    Emitter<InventoryState> emit,
  ) {
    final items = event.items.cast<InventoryItem>();
    emit(state.copyWith(
      status: InventoryStatus.streaming,
      items: items,
      summary: InventorySummary.fromItems(items, repository.inventoryDate),
      inventoryDate: repository.inventoryDate,
      isStreaming: true,
      currentOffset: items.length,
    ));
  }

  /// Handle errors
  void _onInventoryError(
    InventoryError event,
    Emitter<InventoryState> emit,
  ) {
    emit(state.error(event.message));
  }

  /// Refresh data based on current mode (reset to initial chunk)
  Future<void> _refreshData(Emitter<InventoryState> emit) async {
    if (_itemsSubscription != null) {
      // Re-subscribe with new filters
      await _itemsSubscription?.cancel();
      _itemsSubscription = repository
          .watchItemsChunked(
            tabType: state.selectedTab,
            offset: 0,
            limit: InventoryState.initialChunkSize,
            searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
            filters: state.filters,
          )
          .listen(
            (result) => add(ItemsUpdated(result.items)),
            onError: (error) => add(InventoryError(error.toString())),
          );
    } else {
      // Just reload first chunk
      try {
        final result = await repository.getItemsChunked(
          tabType: state.selectedTab,
          offset: 0,
          limit: InventoryState.initialChunkSize,
          searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
          filters: state.filters,
        );

        emit(state.copyWith(
          status: InventoryStatus.loaded,
          items: result.items,
          hasMore: result.hasMore,
          totalCount: result.totalCount,
          currentOffset: result.items.length,
          summary: InventorySummary.fromItems(result.items, repository.inventoryDate),
          inventoryDate: repository.inventoryDate,
        ));
      } catch (e) {
        emit(state.error(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    return super.close();
  }
}
