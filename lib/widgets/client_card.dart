import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ClientCard extends StatefulWidget {
  final ClientApiItem client;
  final VoidCallback? onTap;

  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
  });

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  // Metric colors
  static const Color _rucColor = Color(0xFF0EA5E9); // Sky blue
  static const Color _giroColor = Color(0xFF8B5CF6); // Purple
  static const Color _statusColor = Color(0xFF16A34A); // Green

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
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
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
                  // Client Name (Title)
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      _truncateName(widget.client.nombre, 45),
                      style: AppTheme.itemTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle with icon - Company & Branch
                  Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 12,
                        color: AppTheme.textGray.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.client.compania} · ${widget.client.sucursal}',
                          style: AppTheme.itemSubtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Info chips row
                  _buildInfoChipsRow(),
                  const SizedBox(height: 10),

                  // Address with icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.client.direccion,
                          style: AppTheme.itemSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bottom row with district and ERP code
                  Row(
                    children: [
                      _buildDistrictBadge(),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                size: 12,
                                color: AppTheme.textGray.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ERP: ${widget.client.codigoErp}',
                                style: AppTheme.positionText,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fingerprint_rounded,
                                size: 12,
                                color: AppTheme.textGray.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ID: ${widget.client.id}',
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

            // Status indicator (active/inactive)
            Positioned(
              top: AppTheme.spacingL,
              right: AppTheme.spacingL,
              child: _buildStatusIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChipsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildInfoChip(
          'RUC',
          widget.client.ruc,
          Icons.badge_rounded,
          _rucColor,
        ),
        _buildInfoChip(
          'GIRO',
          widget.client.giroCliente,
          Icons.store_rounded,
          _giroColor,
        ),
        if (widget.client.latitud != null && widget.client.longitud != null)
          _buildInfoChip(
            'GPS',
            'Disponible',
            Icons.gps_fixed_rounded,
            _statusColor,
          ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
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
            value.length > 15 ? '${value.substring(0, 12)}...' : value,
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

  Widget _buildDistrictBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.place_rounded,
            size: 14,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            widget.client.coloniaNombre.length > 20
                ? '${widget.client.coloniaNombre.substring(0, 17)}...'
                : widget.client.coloniaNombre,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isActive = widget.client.activo;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accentGreen.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isActive ? AppTheme.accentGreen : Colors.red).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
        size: 20,
        color: isActive ? AppTheme.accentGreen : Colors.red,
      ),
    );
  }
}
