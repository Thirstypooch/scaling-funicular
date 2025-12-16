import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;
  StreamSubscription<List<InventoryItem>>? _itemsSubscription;

  InventoryBloc({required this.repository}) : super(InventoryState.initial()) {
    on<LoadInventory>(_onLoadInventory);
    on<SubscribeToInventory>(_onSubscribeToInventory);
    on<UnsubscribeFromInventory>(_onUnsubscribeFromInventory);
    on<ChangeTab>(_onChangeTab);
    on<UpdateSearch>(_onUpdateSearch);
    on<UpdateFilter>(_onUpdateFilter);
    on<ResetFilters>(_onResetFilters);
    on<ItemsUpdated>(_onItemsUpdated);
    on<InventoryError>(_onInventoryError);
  }

  /// Load inventory data once (no streaming)
  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.loading());

    try {
      final items = await repository.getFilteredItems(
        tabType: state.selectedTab,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        filters: state.filters,
      );

      emit(state.loaded(
        items: items,
        date: repository.inventoryDate,
        streaming: false,
      ));
    } catch (e) {
      emit(state.error(e.toString()));
    }
  }

  /// Subscribe to real-time inventory updates
  Future<void> _onSubscribeToInventory(
    SubscribeToInventory event,
    Emitter<InventoryState> emit,
  ) async {
    await _itemsSubscription?.cancel();

    emit(state.loading());

    _itemsSubscription = repository
        .watchFilteredItems(
          tabType: state.selectedTab,
          searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
          filters: state.filters,
        )
        .listen(
          (items) => add(ItemsUpdated(items)),
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

  /// Change the selected tab
  Future<void> _onChangeTab(
    ChangeTab event,
    Emitter<InventoryState> emit,
  ) async {
    if (event.tabType == state.selectedTab) return;

    emit(state.copyWith(
      selectedTab: event.tabType,
      status: InventoryStatus.loading,
    ));

    // Re-subscribe or reload based on current mode
    if (state.isStreaming || _itemsSubscription != null) {
      await _itemsSubscription?.cancel();
      _itemsSubscription = repository
          .watchFilteredItems(
            tabType: event.tabType,
            searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
            filters: state.filters,
          )
          .listen(
            (items) => add(ItemsUpdated(items)),
            onError: (error) => add(InventoryError(error.toString())),
          );
    } else {
      try {
        final items = await repository.getFilteredItems(
          tabType: event.tabType,
          searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
          filters: state.filters,
        );
        emit(state.copyWith(selectedTab: event.tabType).loaded(
          items: items,
          date: repository.inventoryDate,
        ));
      } catch (e) {
        emit(state.copyWith(selectedTab: event.tabType).error(e.toString()));
      }
    }
  }

  /// Update search query
  Future<void> _onUpdateSearch(
    UpdateSearch event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));

    // Debounce search - in a real app, use a debounce transformer
    await _refreshData(emit);
  }

  /// Update a filter value
  Future<void> _onUpdateFilter(
    UpdateFilter event,
    Emitter<InventoryState> emit,
  ) async {
    final newFilters = Map<String, String>.from(state.filters);
    newFilters[event.filterKey] = event.filterValue;

    emit(state.copyWith(filters: newFilters));
    await _refreshData(emit);
  }

  /// Reset all filters
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
    ));
    await _refreshData(emit);
  }

  /// Handle items updated from stream
  void _onItemsUpdated(
    ItemsUpdated event,
    Emitter<InventoryState> emit,
  ) {
    final items = event.items.cast<InventoryItem>();
    emit(state.loaded(
      items: items,
      date: repository.inventoryDate,
      streaming: true,
    ));
  }

  /// Handle errors
  void _onInventoryError(
    InventoryError event,
    Emitter<InventoryState> emit,
  ) {
    emit(state.error(event.message));
  }

  /// Refresh data based on current mode
  Future<void> _refreshData(Emitter<InventoryState> emit) async {
    if (_itemsSubscription != null) {
      // Re-subscribe with new filters
      await _itemsSubscription?.cancel();
      _itemsSubscription = repository
          .watchFilteredItems(
            tabType: state.selectedTab,
            searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
            filters: state.filters,
          )
          .listen(
            (items) => add(ItemsUpdated(items)),
            onError: (error) => add(InventoryError(error.toString())),
          );
    } else {
      // Just reload once
      try {
        final items = await repository.getFilteredItems(
          tabType: state.selectedTab,
          searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
          filters: state.filters,
        );
        emit(state.loaded(
          items: items,
          date: repository.inventoryDate,
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
