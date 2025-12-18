import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Data model for KPI breakdown items
class KpiBreakdownItem {
  final String label;
  final int value;
  final double percentage;
  final Color? color;

  const KpiBreakdownItem({
    required this.label,
    required this.value,
    required this.percentage,
    this.color,
  });
}

/// Detailed KPI Modal with charts and breakdown
class KpiDetailModal extends StatefulWidget {
  final String title;
  final int value;
  final int? previousValue;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<double> chartData;
  final List<KpiBreakdownItem>? breakdown;

  const KpiDetailModal({
    super.key,
    required this.title,
    required this.value,
    this.previousValue,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.chartData,
    this.breakdown,
  });

  @override
  State<KpiDetailModal> createState() => _KpiDetailModalState();
}

class _KpiDetailModalState extends State<KpiDetailModal>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _countController;
  late AnimationController _breakdownController;

  late Animation<double> _chartAnimation;
  late Animation<int> _countAnimation;
  late Animation<double> _breakdownAnimation;

  int _displayValue = 0;

  @override
  void initState() {
    super.initState();

    // Chart animation
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );

    // Count animation
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _countAnimation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
    );
    _countController.addListener(() {
      setState(() => _displayValue = _countAnimation.value);
    });

    // Breakdown animation
    _breakdownController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _breakdownAnimation = CurvedAnimation(
      parent: _breakdownController,
      curve: Curves.easeOutCubic,
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _countController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _chartController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _breakdownController.forward();
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
    _countController.dispose();
    _breakdownController.dispose();
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

  List<String> get _dayLabels {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      return ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'][day.weekday % 7];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Main value section
                  _buildMainValue(),
                  const SizedBox(height: 32),

                  // Chart section
                  _buildChartSection(),
                  const SizedBox(height: 32),

                  // Stats grid
                  _buildStatsGrid(),

                  // Breakdown section
                  if (widget.breakdown != null && widget.breakdown!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildBreakdownSection(),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor,
                widget.secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textGrayDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGray,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: AppTheme.textGray,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainValue() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor.withValues(alpha: 0.1),
            widget.secondaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valor actual',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textGray,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatNumber(_displayValue),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: widget.primaryColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'unidades',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_trendPercentage != null) _buildTrendBadge(),
        ],
      ),
    );
  }

  Widget _buildTrendBadge() {
    final trend = _trendPercentage!;
    final isPositive = trend >= 0;
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 28,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  'vs ayer',
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tendencia (7 días)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGrayDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Diario',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _chartController,
          builder: (context, _) {
            return Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(
                size: const Size(double.infinity, 148),
                painter: _DetailedChartPainter(
                  data: widget.chartData,
                  progress: _chartAnimation.value,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  labels: _dayLabels,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatItem(
        label: 'Promedio',
        value: widget.chartData.isNotEmpty
            ? (widget.chartData.reduce((a, b) => a + b) / widget.chartData.length).round()
            : 0,
        icon: Icons.analytics_rounded,
        color: const Color(0xFF6366F1),
      ),
      _StatItem(
        label: 'Máximo',
        value: widget.chartData.isNotEmpty
            ? widget.chartData.reduce(math.max).round()
            : 0,
        icon: Icons.arrow_upward_rounded,
        color: const Color(0xFF10B981),
      ),
      _StatItem(
        label: 'Mínimo',
        value: widget.chartData.isNotEmpty
            ? widget.chartData.reduce(math.min).round()
            : 0,
        icon: Icons.arrow_downward_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _StatItem(
        label: 'Variación',
        value: widget.chartData.length >= 2
            ? (widget.chartData.last - widget.chartData.first).round().abs()
            : 0,
        icon: Icons.swap_vert_rounded,
        color: const Color(0xFFEC4899),
      ),
    ];

    return AnimatedBuilder(
      animation: _breakdownController,
      builder: (context, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            final delay = index * 0.15;
            final progress = ((_breakdownAnimation.value - delay) / (1 - delay))
                .clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(0, 20 * (1 - progress)),
              child: Opacity(
                opacity: progress,
                child: _buildStatCard(stat),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stat.color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 16, color: stat.color),
              const SizedBox(width: 6),
              Text(
                stat.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatNumber(stat.value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: stat.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection() {
    return AnimatedBuilder(
      animation: _breakdownController,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Desglose por categoría',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGrayDark,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.breakdown!.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final delay = index * 0.1;
              final progress = ((_breakdownAnimation.value - delay) / (1 - delay))
                  .clamp(0.0, 1.0);

              return Transform.translate(
                offset: Offset(30 * (1 - progress), 0),
                child: Opacity(
                  opacity: progress,
                  child: _buildBreakdownItem(item, progress),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildBreakdownItem(KpiBreakdownItem item, double progress) {
    final color = item.color ?? widget.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textGrayDark,
                ),
              ),
              Text(
                '${_formatNumber(item.value)} (${item.percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (item.percentage / 100) * progress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// Detailed chart painter with labels and grid
class _DetailedChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> labels;

  _DetailedChartPainter({
    required this.data,
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartHeight = size.height - 30;
    final chartWidth = size.width;

    final maxValue = data.reduce(math.max);
    final minValue = data.reduce(math.min);
    final range = maxValue - minValue;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = chartHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // Draw gradient fill
    final fillPath = Path();
    final linePath = Path();

    final pointCount = (data.length * progress).ceil();
    final stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < pointCount; i++) {
      final x = i * stepX;
      final normalizedY = range == 0 ? 0.5 : (data[i] - minValue) / range;
      final y = chartHeight - (normalizedY * chartHeight * 0.85) - chartHeight * 0.05;

      if (i == 0) {
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
        linePath.moveTo(x, y);
      } else {
        // Smooth curve
        final prevX = (i - 1) * stepX;
        final prevNormalizedY = range == 0 ? 0.5 : (data[i - 1] - minValue) / range;
        final prevY = chartHeight - (prevNormalizedY * chartHeight * 0.85) - chartHeight * 0.05;

        final cpX = (prevX + x) / 2;

        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
        linePath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    // Complete fill path
    if (pointCount > 0) {
      final lastX = (pointCount - 1) * stepX;
      fillPath.lineTo(lastX, chartHeight);
      fillPath.close();
    }

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.4),
          primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw points and labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = range == 0 ? 0.5 : (data[i] - minValue) / range;
      final y = chartHeight - (normalizedY * chartHeight * 0.85) - chartHeight * 0.05;

      // Draw point
      if (progress > i / data.length) {
        final pointProgress = ((progress - i / data.length) * data.length).clamp(0.0, 1.0);

        // Glow
        final glowPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.3 * pointProgress)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 6 * pointProgress, glowPaint);

        // Point
        final pointPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 4 * pointProgress, pointPaint);

        // White center
        final centerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 2 * pointProgress, centerPaint);
      }

      // Draw day label
      if (i < labels.length) {
        textPainter.text = TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.withValues(alpha: 0.8),
            fontWeight: i == data.length - 1 ? FontWeight.w600 : FontWeight.w400,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - 14),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}

/// Helper function to show the KPI detail modal
void showKpiDetailModal(
  BuildContext context, {
  required String title,
  required int value,
  int? previousValue,
  required String subtitle,
  required IconData icon,
  required Color primaryColor,
  required Color secondaryColor,
  required List<double> chartData,
  List<KpiBreakdownItem>? breakdown,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return KpiDetailModal(
          title: title,
          value: value,
          previousValue: previousValue,
          subtitle: subtitle,
          icon: icon,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          chartData: chartData,
          breakdown: breakdown,
        );
      },
    ),
  );
}
