import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import '../theme/app_theme.dart';
import 'inventory_item_card.dart';
import 'custom_pull_to_refresh.dart';

class InventoryList extends StatefulWidget {
  final List<InventoryItem> items;
  final TabType tabType;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;

  const InventoryList({
    super.key,
    required this.items,
    required this.tabType,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.onLoadMore,
    this.onRefresh,
  });

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  final ScrollController _scrollController = ScrollController();
  List<InventoryItem> _previousItems = [];
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InventoryList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if this is a fresh load (tab change, search, filter) vs load more
    if (oldWidget.tabType != widget.tabType) {
      _isInitialLoad = true;
      _previousItems = [];
    } else if (widget.items.length < oldWidget.items.length) {
      // Items were reset (new search/filter)
      _isInitialLoad = true;
      _previousItems = [];
    } else if (widget.items.length > _previousItems.length && !_isInitialLoad) {
      // More items were loaded
      _previousItems = List.from(widget.items);
    } else if (_isInitialLoad && widget.items.isNotEmpty) {
      _isInitialLoad = false;
      _previousItems = List.from(widget.items);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Near the bottom, trigger load more
      if (widget.hasMore && !widget.isLoadingMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No se encontraron resultados',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => widget.onRefresh?.call(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualizar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                ),
              ),
            ],
          ],
        ),
      );
    }

    final listView = ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.zero,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index == widget.items.length) {
          return _buildLoadingIndicator();
        }

        return TweenAnimationBuilder<double>(
          key: ValueKey('${widget.tabType}_${widget.items[index].id}'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index % 5) * 50),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: InventoryItemCard(
            item: widget.items[index],
            tabType: widget.tabType,
          ),
        );
      },
    );

    // Wrap with custom pull-to-refresh if onRefresh is provided
    if (widget.onRefresh != null) {
      return CustomPullToRefresh(
        onRefresh: widget.onRefresh!,
        scrollController: _scrollController,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cargando más...',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
