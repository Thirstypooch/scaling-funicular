import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'summary_card.dart';

class SummaryCardsRow extends StatelessWidget {
  final int sellOut;
  final int inventory;
  final int sellIn;
  final int registros;
  final int skus;
  final String date;

  const SummaryCardsRow({
    super.key,
    required this.sellOut,
    required this.inventory,
    required this.sellIn,
    required this.registros,
    required this.skus,
    required this.date,
  });

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
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: 'SellOut total (unid.)',
            value: _formatNumber(sellOut),
            subtitle: 'Registros: $registros',
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF16A34A), // Green
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: SummaryCard(
            title: 'Inventario final (unid.)',
            value: _formatNumber(inventory),
            subtitle: date,
            icon: Icons.inventory_rounded,
            iconColor: const Color(0xFF0EA5E9), // Blue
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: SummaryCard(
            title: 'SellIn total (unid.)',
            value: _formatNumber(sellIn),
            subtitle: 'SKUs distintos: $skus',
            icon: Icons.shopping_cart_rounded,
            iconColor: const Color(0xFF8B5CF6), // Purple
          ),
        ),
      ],
    );
  }
}
