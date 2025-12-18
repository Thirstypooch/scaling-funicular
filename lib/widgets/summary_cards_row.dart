import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animated_kpi_card.dart';

class SummaryCardsRow extends StatelessWidget {
  final int sellOut;
  final int inventory;
  final int sellIn;
  final int registros;
  final int skus;
  final String date;
  final int? previousSellOut;
  final int? previousInventory;
  final int? previousSellIn;

  const SummaryCardsRow({
    super.key,
    required this.sellOut,
    required this.inventory,
    required this.sellIn,
    required this.registros,
    required this.skus,
    required this.date,
    this.previousSellOut,
    this.previousInventory,
    this.previousSellIn,
  });

  // Generate sample sparkline data based on current value
  List<double> _generateSparklineData(int currentValue, {bool trending = true}) {
    final base = currentValue.toDouble();
    final variance = base * 0.15;

    // Generate 7 data points (last 7 days)
    return List.generate(7, (index) {
      if (index == 6) return base; // Current value is last point

      final factor = trending
          ? 0.7 + (index * 0.05) // Trending up
          : 1.0 - (index * 0.02) + (index.isEven ? 0.05 : -0.05); // Fluctuating

      return (base * factor) + (variance * (index.isEven ? 0.5 : -0.3));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // SellOut Card
        Expanded(
          child: AnimatedKpiCard(
            title: 'SellOut total',
            value: sellOut,
            previousValue: previousSellOut,
            subtitle: 'Registros: $registros',
            icon: Icons.trending_up_rounded,
            primaryColor: const Color(0xFF10B981), // Emerald
            secondaryColor: const Color(0xFF059669),
            animationDelay: 0,
            sparklineData: _generateSparklineData(sellOut, trending: true),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),

        // Inventory Card
        Expanded(
          child: AnimatedKpiCard(
            title: 'Inventario',
            value: inventory,
            previousValue: previousInventory,
            subtitle: date,
            icon: Icons.inventory_2_rounded,
            primaryColor: const Color(0xFF3B82F6), // Blue
            secondaryColor: const Color(0xFF2563EB),
            animationDelay: 150,
            sparklineData: _generateSparklineData(inventory, trending: false),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),

        // SellIn Card
        Expanded(
          child: AnimatedKpiCard(
            title: 'SellIn total',
            value: sellIn,
            previousValue: previousSellIn,
            subtitle: 'SKUs: $skus',
            icon: Icons.shopping_cart_rounded,
            primaryColor: const Color(0xFF8B5CF6), // Purple
            secondaryColor: const Color(0xFF7C3AED),
            animationDelay: 300,
            sparklineData: _generateSparklineData(sellIn, trending: true),
          ),
        ),
      ],
    );
  }
}
