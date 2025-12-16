import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterDropdown extends StatefulWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String>? onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    this.onChanged,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: AppTheme.cardWhite,
      end: AppTheme.backgroundGray,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    _showDropdownMenu();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTheme.filterLabel,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.value,
                  style: AppTheme.filterValue,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppTheme.textGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDropdownMenu() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        0,
      ),
      items: widget.options.map((option) {
        final isSelected = option == widget.value;
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (isSelected)
                const Icon(
                  Icons.check,
                  size: 16,
                  color: AppTheme.primaryBlue,
                )
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(
                option,
                style: isSelected
                    ? AppTheme.filterValue.copyWith(color: AppTheme.primaryBlue)
                    : AppTheme.filterValue,
              ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedValue) {
      if (selectedValue != null && widget.onChanged != null) {
        widget.onChanged!(selectedValue);
      }
    });
  }
}
