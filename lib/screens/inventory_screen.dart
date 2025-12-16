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
    _searchController.dispose();
    super.dispose();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToLoadScreen,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Cargar inventario',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
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
                    onChanged: (value) {
                      context.read<InventoryBloc>().add(UpdateSearch(value));
                    },
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

                // Group header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: Text(
                    'Agrupado por ${state.selectedTab.groupLabel}',
                    style: AppTheme.groupHeader,
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
        );
    }
  }
}
