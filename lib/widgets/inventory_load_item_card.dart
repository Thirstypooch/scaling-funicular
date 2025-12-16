import 'package:flutter/material.dart';
import '../models/inventory_load_item.dart';
import '../theme/app_theme.dart';

class InventoryLoadItemCard extends StatefulWidget {
  final InventoryLoadItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InventoryLoadItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<InventoryLoadItemCard> createState() => _InventoryLoadItemCardState();
}

class _InventoryLoadItemCardState extends State<InventoryLoadItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title: depends on groupType
                        _buildTitle(),
                        const SizedBox(height: 4),

                        // Subtitle: Agrupación
                        Text(
                          _buildSubtitle(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        color: AppTheme.textGray,
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.textGray,
                        onTap: widget.onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildCategoryChip('Cat', widget.item.categoria),
                  _buildCategoryChip('Sub', widget.item.subcategoria),
                  _buildCategoryChip('Fam', widget.item.familia),
                  _buildCategoryChip('SubFam', widget.item.subfamilia),
                ],
              ),
              const SizedBox(height: 10),

              // Quantity row (simple text format)
              Row(
                children: [
                  Text(
                    'Cajas: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrayDark,
                    ),
                  ),
                  Text(
                    '${widget.item.cajas}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Unidades: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrayDark,
                    ),
                  ),
                  Text(
                    '${widget.item.unidades}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom row: badge and timestamp
              Row(
                children: [
                  if (widget.item.isLoaded) _buildLoadedBadge(),
                  const Spacer(),
                  Text(
                    '12:00 p. m.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    // For SKU groupType, show "SKU — Name" format
    if (widget.item.groupType == InventoryGroupType.sku && widget.item.sku.isNotEmpty) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.item.sku,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
            TextSpan(
              text: ' — ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textGrayDark,
              ),
            ),
            TextSpan(
              text: widget.item.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textGrayDark,
              ),
            ),
          ],
        ),
      );
    }

    // For other groupTypes, just show the name
    return Text(
      widget.item.name,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textGrayDark,
      ),
    );
  }

  String _buildSubtitle() {
    final groupLabel = widget.item.groupType.label;

    if (widget.item.groupType == InventoryGroupType.sku && widget.item.familia.isNotEmpty) {
      return 'Agrupación: $groupLabel · Inventario para promo ${widget.item.familia}';
    }

    return 'Agrupación: $groupLabel · Inventario';
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String prefix, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$prefix: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textGray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGrayDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        'Inventario cargado',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.accentGreen,
        ),
      ),
    );
  }
}
