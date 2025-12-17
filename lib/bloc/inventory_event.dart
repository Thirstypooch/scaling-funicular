import 'package:equatable/equatable.dart';
import '../models/tab_type.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial inventory data
class LoadInventory extends InventoryEvent {
  const LoadInventory();
}

/// Subscribe to real-time inventory updates
class SubscribeToInventory extends InventoryEvent {
  const SubscribeToInventory();
}

/// Unsubscribe from real-time updates
class UnsubscribeFromInventory extends InventoryEvent {
  const UnsubscribeFromInventory();
}

/// Change the current tab (SKU, Categoría, etc.)
class ChangeTab extends InventoryEvent {
  final TabType tabType;

  const ChangeTab(this.tabType);

  @override
  List<Object?> get props => [tabType];
}

/// Update search query
class UpdateSearch extends InventoryEvent {
  final String query;

  const UpdateSearch(this.query);

  @override
  List<Object?> get props => [query];
}

/// Update a filter value
class UpdateFilter extends InventoryEvent {
  final String filterKey;
  final String filterValue;

  const UpdateFilter({
    required this.filterKey,
    required this.filterValue,
  });

  @override
  List<Object?> get props => [filterKey, filterValue];
}

/// Reset all filters to default
class ResetFilters extends InventoryEvent {
  const ResetFilters();
}

/// Load more items for infinite scrolling
class LoadMoreItems extends InventoryEvent {
  const LoadMoreItems();
}

/// Refresh inventory data (pull-to-refresh)
class RefreshInventory extends InventoryEvent {
  const RefreshInventory();
}

/// Internal event when new items are received from stream
class ItemsUpdated extends InventoryEvent {
  final List<dynamic> items;

  const ItemsUpdated(this.items);

  @override
  List<Object?> get props => [items];
}

/// Internal event when an error occurs
class InventoryError extends InventoryEvent {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
