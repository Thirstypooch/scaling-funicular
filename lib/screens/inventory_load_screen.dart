import 'package:flutter/material.dart';
import '../models/inventory_load_item.dart';
import '../theme/app_theme.dart';
import '../widgets/client_info_card.dart';
import '../widgets/inventory_load_item_card.dart';
import '../widgets/inventory_detail_modal.dart';

class InventoryLoadScreen extends StatefulWidget {
  const InventoryLoadScreen({super.key});

  @override
  State<InventoryLoadScreen> createState() => _InventoryLoadScreenState();
}

class _InventoryLoadScreenState extends State<InventoryLoadScreen> {
  late List<InventoryLoadItem> _items;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _items = List.from(MockInventoryLoadData.items);
  }

  void _addItem(InventoryLoadItem item) {
    setState(() {
      _items.insert(0, item);
    });
    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
  }

  void _editItem(int index, InventoryLoadItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  void _deleteItem(int index) {
    final removedItem = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedItem(removedItem, animation, index),
      duration: const Duration(milliseconds: 300),
    );
  }

  void _showAddDialog() {
    showInventoryDetailModal(
      context,
      onSave: _addItem,
    );
  }

  void _showEditDialog(int index) {
    showInventoryDetailModal(
      context,
      item: _items[index],
      onSave: (item) => _editItem(index, item),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Eliminar producto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Está seguro que desea eliminar "${_items[index].name}"?',
          style: TextStyle(
            color: AppTheme.textGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spacingL),

                    // Client info card
                    ClientInfoCard(
                      clientName: MockInventoryLoadData.clientName,
                      date: MockInventoryLoadData.loadDate,
                    ),
                    const SizedBox(height: AppTheme.spacingL),

                    // Add product button
                    _buildAddButton(),
                    const SizedBox(height: AppTheme.spacingL),

                    // Items count
                    Row(
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
                          'Productos cargados',
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
                            '${_items.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),

                    // Items list
                    Expanded(
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount: _items.length,
                        itemBuilder: (context, index, animation) {
                          return _buildAnimatedItem(_items[index], animation, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                const Text(
                  'Carga de inventario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gestiona el inventario del cliente',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGreen.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Agregar producto',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(
    InventoryLoadItem item,
    Animation<double> animation,
    int index,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: InventoryLoadItemCard(
          item: item,
          onEdit: () => _showEditDialog(index),
          onDelete: () => _showDeleteConfirmation(index),
        ),
      ),
    );
  }
}
