import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../models/tab_type.dart';
import 'inventory_item_card.dart';

class InventoryList extends StatefulWidget {
  final List<InventoryItem> items;
  final TabType tabType;

  const InventoryList({
    super.key,
    required this.items,
    required this.tabType,
  });

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<InventoryItem> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _animateItemsIn();
  }

  @override
  void didUpdateWidget(InventoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items || oldWidget.tabType != widget.tabType) {
      _animateItemsIn();
    }
  }

  void _animateItemsIn() {
    _displayedItems = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listKey.currentState?.removeAllItems(
        (context, animation) => const SizedBox.shrink(),
        duration: Duration.zero,
      );

      for (int i = 0; i < widget.items.length; i++) {
        Future.delayed(Duration(milliseconds: 50 * i), () {
          if (mounted && i < widget.items.length) {
            _displayedItems.add(widget.items[i]);
            _listKey.currentState?.insertItem(
              i,
              duration: const Duration(milliseconds: 300),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      padding: EdgeInsets.zero,
      initialItemCount: 0,
      itemBuilder: (context, index, animation) {
        if (index >= _displayedItems.length) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: FadeTransition(
            opacity: animation.drive(
              CurveTween(curve: Curves.easeOut),
            ),
            child: InventoryItemCard(
              item: _displayedItems[index],
              tabType: widget.tabType,
            ),
          ),
        );
      },
    );
  }
}
