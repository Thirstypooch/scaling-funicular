import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import '../theme/app_theme.dart';

class InventoryItemCard extends StatefulWidget {
  final InventoryItem item;
  final TabType tabType;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.tabType,
  });

  @override
  State<InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<InventoryItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  // Metric colors
  static const Color _invColor = Color(0xFF0EA5E9); // Sky blue
  static const Color _sellInColor = Color(0xFF8B5CF6); // Purple
  static const Color _sellOutColor = Color(0xFF16A34A); // Green

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04 * _elevationAnimation.value),
                    blurRadius: 8 * _elevationAnimation.value,
                    offset: Offset(0, 2 * _elevationAnimation.value),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      widget.item.getDisplayTitle(widget.tabType),
                      style: AppTheme.itemTitle,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle with icon
                  Row(
                    children: [
                      Icon(
                        Icons.layers_rounded,
                        size: 12,
                        color: AppTheme.textGray.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Agrupación: ${widget.item.getGroupTypeLabel(widget.tabType)} · Registros: ${widget.item.registros} · SKUs: ${widget.item.skus}',
                          style: AppTheme.itemSubtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Metrics row with icons
                  _buildMetricsRow(),
                  const SizedBox(height: 6),

                  // Initial inventory with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 10,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Inventario inicial: ${_formatNumber(widget.item.initialInventory)}',
                        style: AppTheme.itemSubtitle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bottom row with badge, position, and timestamp
                  Row(
                    children: [
                      if (widget.item.hasSales) _buildBadge(),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 12,
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Posición: #${widget.item.position}',
                                style: AppTheme.positionText,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: AppTheme.textGray.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.item.timestamp,
                                style: AppTheme.timestampText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Location pin
            Positioned(
              top: AppTheme.spacingL,
              right: AppTheme.spacingL,
              child: _buildLocationPin(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildMetricChip(
          'INV',
          widget.item.inventory,
          Icons.inventory_rounded,
          _invColor,
        ),
        _buildMetricChip(
          'SELLIN',
          widget.item.sellIn,
          Icons.shopping_cart_rounded,
          _sellInColor,
        ),
        _buildMetricChip(
          'SELLOUT',
          widget.item.sellOut,
          Icons.trending_up_rounded,
          _sellOutColor,
        ),
      ],
    );
  }

  Widget _buildMetricChip(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          Text(
            _formatNumber(value),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: AppTheme.accentGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppTheme.accentGreen,
          ),
          const SizedBox(width: 4),
          const Text(
            'Con venta',
            style: AppTheme.badgeText,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPin() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.pinBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.pinOrange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.location_on_rounded,
        size: 20,
        color: AppTheme.pinOrange,
      ),
    );
  }
}
