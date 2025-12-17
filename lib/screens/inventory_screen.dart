import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/tab_type.dart';
import '../theme/app_theme.dart';
import '../widgets/segmented_tab_bar.dart';
import '../widgets/search_field.dart';
import '../widgets/filter_dropdown_row.dart';
import '../widgets/summary_cards_row.dart';
import '../widgets/inventory_list.dart';
import 'inventory_load_screen.dart';

class InventoryScreen extends StatefulWidget {
  /// If true, uses StreamBuilder for real-time updates
  /// If false, loads data once on init and on user actions
  final bool useStreaming;

  const InventoryScreen({
    super.key,
    this.useStreaming = false,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  Timer? _fabCollapseTimer;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load or subscribe to data based on mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.useStreaming) {
        context.read<InventoryBloc>().add(const SubscribeToInventory());
      } else {
        context.read<InventoryBloc>().add(const LoadInventory());
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _fabCollapseTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(seconds: 1), () {
      context.read<InventoryBloc>().add(UpdateSearch(value));
    });
  }

  void _onFabPressed() {
    if (_isFabExpanded) {
      // Navigate when expanded
      _fabCollapseTimer?.cancel();
      _navigateToLoadScreen();
      setState(() => _isFabExpanded = false);
    } else {
      // Expand the FAB
      setState(() => _isFabExpanded = true);
      _startFabCollapseTimer();
    }
  }

  void _startFabCollapseTimer() {
    _fabCollapseTimer?.cancel();
    _fabCollapseTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isFabExpanded = false);
      }
    });
  }

  void _navigateToLoadScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const InventoryLoadScreen(),
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
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      floatingActionButton: _buildAnimatedFab(),
      body: SafeArea(
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streaming indicator
                if (state.isStreaming)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                      vertical: AppTheme.spacingXS,
                    ),
                    color: AppTheme.accentGreen.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGreen.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Datos en tiempo real',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tab bar
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: SegmentedTabBar(
                    selectedTab: state.selectedTab,
                    onTabSelected: (tab) {
                      context.read<InventoryBloc>().add(ChangeTab(tab));
                    },
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: SearchField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Filter dropdowns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: FilterDropdownRow(
                    selectedFilters: state.filters,
                    onFilterChanged: (entry) {
                      context.read<InventoryBloc>().add(UpdateFilter(
                            filterKey: entry.key,
                            filterValue: entry.value,
                          ));
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Summary cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: SummaryCardsRow(
                    sellOut: state.summary?.totalSellOut ?? 0,
                    inventory: state.summary?.totalInventory ?? 0,
                    sellIn: state.summary?.totalSellIn ?? 0,
                    registros: state.summary?.totalRegistros ?? 0,
                    skus: state.summary?.totalSkus ?? 0,
                    date: state.inventoryDate,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Group header with count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: Row(
                    children: [
                      Text(
                        'Agrupado por ${state.selectedTab.groupLabel}',
                        style: AppTheme.groupHeader,
                      ),
                      const SizedBox(width: 8),
                      if (state.status == InventoryStatus.loaded ||
                          state.status == InventoryStatus.streaming)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${state.items.length}${state.hasMore ? '+' : ''} de ${state.totalCount}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                    child: _buildContent(state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedFab() {
    return GestureDetector(
      onTap: _onFabPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: _isFabExpanded ? 20 : 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(_isFabExpanded ? 28 : 28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: _isFabExpanded
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Cargar inventario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(InventoryState state) {
    switch (state.status) {
      case InventoryStatus.initial:
      case InventoryStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
        );

      case InventoryStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGrayDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Error desconocido',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.useStreaming) {
                    context.read<InventoryBloc>().add(const SubscribeToInventory());
                  } else {
                    context.read<InventoryBloc>().add(const LoadInventory());
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );

      case InventoryStatus.loaded:
      case InventoryStatus.streaming:
        return InventoryList(
          items: state.items,
          tabType: state.selectedTab,
          hasMore: state.hasMore,
          isLoadingMore: state.isLoadingMore,
          isRefreshing: state.isRefreshing,
          searchQuery: state.searchQuery,
          onLoadMore: () {
            context.read<InventoryBloc>().add(const LoadMoreItems());
          },
          onRefresh: () async {
            context.read<InventoryBloc>().add(const RefreshInventory());
            // Wait for the refresh to complete
            await Future.delayed(const Duration(milliseconds: 800));
          },
          onSwitchTab: (tab) {
            context.read<InventoryBloc>().add(ChangeTab(tab));
          },
        );
    }
  }
}
