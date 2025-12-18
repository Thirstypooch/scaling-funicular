import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import '../theme/app_theme.dart';
import '../widgets/inventory_item_card.dart';

class InventoryDrilldownScreen extends StatelessWidget {
  final InventoryItem parentItem;
  final TabType parentTabType;

  const InventoryDrilldownScreen({
    super.key,
    required this.parentItem,
    required this.parentTabType,
  });

  @override
  Widget build(BuildContext context) {
    // Get filtered SKU items based on the parent grouping
    final skuItems = _getFilteredSkuItems();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Summary card
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: _buildSummaryCard(),
            ),

            // Items count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.inventory_rounded,
                      size: 14,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SKUs en ${parentItem.getDisplayTitle(parentTabType)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGrayDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${skuItems.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // SKU List
            Expanded(
              child: skuItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                      ),
                      itemCount: skuItems.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 50)),
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
                            item: skuItems[index],
                            tabType: TabType.sku,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentItem.getDisplayTitle(parentTabType),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Detalle por SKU · ${parentTabType.groupLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Inventario',
              parentItem.inventory,
              Icons.inventory_rounded,
              const Color(0xFF0EA5E9),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Sell In',
              parentItem.sellIn,
              Icons.shopping_cart_rounded,
              const Color(0xFF8B5CF6),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Sell Out',
              parentItem.sellOut,
              Icons.trending_up_rounded,
              const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          _formatNumber(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textGrayDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppTheme.textGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay SKUs disponibles',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final formatted = number.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < formatted.length; i++) {
        if (i > 0 && (formatted.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(formatted[i]);
      }
      return buffer.toString();
    }
    return number.toString();
  }

  List<InventoryItem> _getFilteredSkuItems() {
    // Get all SKU items and filter based on parent grouping
    final allSkuItems = MockData.getItemsForTab(TabType.sku);

    switch (parentTabType) {
      case TabType.categoria:
        return allSkuItems
            .where((item) => item.categoria == parentItem.categoria)
            .toList();
      case TabType.subcategoria:
        return allSkuItems
            .where((item) => item.subcategoria == parentItem.subcategoria)
            .toList();
      case TabType.familia:
        return allSkuItems
            .where((item) => item.familia == parentItem.familia)
            .toList();
      case TabType.sku:
        // If already on SKU tab, just return the item itself
        return [parentItem];
    }
  }
}
