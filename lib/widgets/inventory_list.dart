import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import '../theme/app_theme.dart';
import '../screens/inventory_drilldown_screen.dart';
import 'inventory_item_card.dart';
import 'custom_pull_to_refresh.dart';

class InventoryList extends StatefulWidget {
  final List<InventoryItem> items;
  final TabType tabType;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String searchQuery;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final void Function(TabType)? onSwitchTab;

  const InventoryList({
    super.key,
    required this.items,
    required this.tabType,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.searchQuery = '',
    this.onLoadMore,
    this.onRefresh,
    this.onSwitchTab,
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

  void _navigateToDrilldown(InventoryItem item) {
    // Only navigate for non-SKU tabs (drill down to see SKUs)
    if (widget.tabType == TabType.sku) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InventoryDrilldownScreen(
          parentItem: item,
          parentTabType: widget.tabType,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return _buildEmptyState();
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
            onTap: () => _navigateToDrilldown(widget.items[index]),
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

  Widget _buildEmptyState() {
    final hasSearch = widget.searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                size: 36,
                color: AppTheme.primaryBlue.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              hasSearch
                  ? 'Sin resultados para "${widget.searchQuery}"'
                  : 'No hay datos disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGrayDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              hasSearch
                  ? 'No se encontraron resultados que coincidan con tu búsqueda. Verifica el texto o intenta con otros términos.'
                  : 'No hay información de inventario para mostrar en este momento.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGray,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
