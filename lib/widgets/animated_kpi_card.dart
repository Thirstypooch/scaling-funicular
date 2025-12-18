import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'kpi_detail_modal.dart';

/// Animated KPI Card with count-up animation, sparkline, and trend indicator
class AnimatedKpiCard extends StatefulWidget {
  final String title;
  final int value;
  final int? previousValue;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final int animationDelay;
  final List<double>? sparklineData;
  final List<KpiBreakdownItem>? breakdown;

  const AnimatedKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.previousValue,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.animationDelay = 0,
    this.sparklineData,
    this.breakdown,
  });

  @override
  State<AnimatedKpiCard> createState() => _AnimatedKpiCardState();
}

class _AnimatedKpiCardState extends State<AnimatedKpiCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _countController;
  late AnimationController _pulseController;
  late AnimationController _sparklineController;

  late Animation<double> _entranceScale;
  late Animation<double> _entranceOpacity;
  late Animation<Offset> _entranceSlide;
  late Animation<int> _countAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparklineAnimation;

  int _displayValue = 0;
  int _previousDisplayValue = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Entrance animation
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _entranceScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Count-up animation
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _countAnimation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
    );

    _countController.addListener(() {
      setState(() {
        _displayValue = _countAnimation.value;
      });
    });

    // Pulse animation for icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sparkline animation
    _sparklineController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _sparklineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparklineController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _entranceController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _countController.forward();
            _pulseController.forward();
          }
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            _sparklineController.forward();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedKpiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousDisplayValue = _displayValue;
      _countAnimation = IntTween(
        begin: _previousDisplayValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
      );
      _countController.forward(from: 0);
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _countController.dispose();
    _pulseController.dispose();
    _sparklineController.dispose();
    super.dispose();
  }

  double? get _trendPercentage {
    if (widget.previousValue == null || widget.previousValue == 0) return null;
    return ((widget.value - widget.previousValue!) / widget.previousValue!) * 100;
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

  void _openDetailModal() {
    showKpiDetailModal(
      context,
      title: widget.title,
      value: widget.value,
      previousValue: widget.previousValue,
      subtitle: widget.subtitle,
      icon: widget.icon,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
      chartData: widget.sparklineData ?? [],
      breakdown: widget.breakdown,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _pulseController]),
      builder: (context, child) {
        return Opacity(
          opacity: _entranceOpacity.value,
          child: SlideTransition(
            position: _entranceSlide,
            child: Transform.scale(
              scale: _entranceScale.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: _openDetailModal,
        child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              widget.primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.primaryColor.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.primaryColor.withValues(alpha: 0.2),
                          widget.secondaryColor.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 14,
                      color: widget.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textGray,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Main value with count-up animation
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(_displayValue),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textGrayDark,
                    height: 1,
                  ),
                ),
                if (_trendPercentage != null) ...[
                  const SizedBox(width: 6),
                  _buildTrendIndicator(),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Sparkline
            if (widget.sparklineData != null && widget.sparklineData!.isNotEmpty)
              AnimatedBuilder(
                animation: _sparklineController,
                builder: (context, _) {
                  return SizedBox(
                    height: 24,
                    child: CustomPaint(
                      size: const Size(double.infinity, 24),
                      painter: _SparklinePainter(
                        data: widget.sparklineData!,
                        progress: _sparklineAnimation.value,
                        color: widget.primaryColor,
                      ),
                    ),
                  );
                },
              ),

            if (widget.sparklineData != null) const SizedBox(height: 6),

            // Subtitle
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textGray.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final trend = _trendPercentage!;
    final isPositive = trend >= 0;
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 10,
                  color: color,
                ),
                const SizedBox(width: 2),
                Text(
                  '${isPositive ? '+' : ''}${trend.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for sparkline chart
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color color;

  _SparklinePainter({
    required this.data,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.reduce(math.max);
    final minValue = data.reduce(math.min);
    final range = maxValue - minValue;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final pointCount = (data.length * progress).ceil();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < pointCount; i++) {
      final x = i * stepX;
      final normalizedY = range == 0 ? 0.5 : (data[i] - minValue) / range;
      final y = size.height - (normalizedY * size.height * 0.8) - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    if (pointCount > 0) {
      final lastX = (pointCount - 1) * stepX;
      fillPath.lineTo(lastX, size.height);
      fillPath.close();
    }

    // Draw fill
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw end point
    if (pointCount > 0 && progress > 0.5) {
      final lastIndex = pointCount - 1;
      final x = lastIndex * stepX;
      final normalizedY = range == 0 ? 0.5 : (data[lastIndex] - minValue) / range;
      final y = size.height - (normalizedY * size.height * 0.8) - size.height * 0.1;

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4, glowPaint);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
