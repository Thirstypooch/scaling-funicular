import 'package:flutter/material.dart';
import '../models/inventory_load_item.dart';
import '../theme/app_theme.dart';

class InventoryDetailModal extends StatefulWidget {
  final InventoryLoadItem? item; // null for new item, non-null for editing
  final Function(InventoryLoadItem) onSave;

  const InventoryDetailModal({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<InventoryDetailModal> createState() => _InventoryDetailModalState();
}

class _InventoryDetailModalState extends State<InventoryDetailModal> {
  late String _selectedCategoria;
  late String _selectedSubcategoria;
  late String _selectedFamilia;
  late String _selectedSubfamilia;
  late String _selectedProducto;
  late TextEditingController _cajasController;
  late TextEditingController _unidadesController;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    _selectedCategoria = widget.item?.categoria ?? 'Todos';
    _selectedSubcategoria = widget.item?.subcategoria ?? 'Todos';
    _selectedFamilia = widget.item?.familia ?? 'Todos';
    _selectedSubfamilia = widget.item?.subfamilia ?? 'Todos';
    _selectedProducto = widget.item?.name ?? '';

    _cajasController = TextEditingController(
      text: widget.item?.cajas.toString() ?? '',
    );
    _unidadesController = TextEditingController(
      text: widget.item?.unidades.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _cajasController.dispose();
    _unidadesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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

          // Header
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 20,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEditing ? 'Editar inventario' : 'Detalle de inventario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGrayDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
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
            ),
          ),

          const Divider(height: 1),

          // Form content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdowns in 2x2 grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Categoria',
                          value: _selectedCategoria,
                          options: MockInventoryLoadData.categorias,
                          icon: Icons.category_rounded,
                          color: const Color(0xFF0EA5E9),
                          onChanged: (value) {
                            setState(() => _selectedCategoria = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Sub Categoria',
                          value: _selectedSubcategoria,
                          options: MockInventoryLoadData.subcategorias,
                          icon: Icons.subdirectory_arrow_right_rounded,
                          color: const Color(0xFF8B5CF6),
                          onChanged: (value) {
                            setState(() => _selectedSubcategoria = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Familia',
                          value: _selectedFamilia,
                          options: MockInventoryLoadData.familias,
                          icon: Icons.family_restroom_rounded,
                          color: const Color(0xFF16A34A),
                          onChanged: (value) {
                            setState(() => _selectedFamilia = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Sub Familia',
                          value: _selectedSubfamilia,
                          options: MockInventoryLoadData.subfamilias,
                          icon: Icons.account_tree_rounded,
                          color: const Color(0xFFF59E0B),
                          onChanged: (value) {
                            setState(() => _selectedSubfamilia = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product search field
                  _buildProductSearchField(),
                  const SizedBox(height: 20),

                  // Quantity inputs
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberInputField(
                          label: 'Cajas',
                          controller: _cajasController,
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFF0EA5E9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberInputField(
                          label: 'Unidades',
                          controller: _unidadesController,
                          icon: Icons.grid_view_rounded,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.save_rounded : Icons.add_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Guardar cambios' : 'Agregar producto',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required IconData icon,
    required Color color,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: color,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(10),
              dropdownColor: AppTheme.cardWhite,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrayDark,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.search_rounded, size: 14, color: AppTheme.primaryBlue),
            const SizedBox(width: 6),
            Text(
              'Producto',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Autocomplete<String>(
            initialValue: TextEditingValue(text: _selectedProducto),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return MockInventoryLoadData.productos;
              }
              return MockInventoryLoadData.productos.where((option) {
                return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
              });
            },
            onSelected: (String selection) {
              setState(() => _selectedProducto = selection);
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar producto...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGray.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  suffixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                  ),
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textGrayDark,
                ),
                onChanged: (value) => _selectedProducto = value,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    width: MediaQuery.of(context).size.width - 64,
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(
                            option,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    final cajas = int.tryParse(_cajasController.text) ?? 0;
    final unidades = int.tryParse(_unidadesController.text) ?? 0;

    // Determine name and groupType based on what was selected
    String name;
    InventoryGroupType groupType;
    String sku;

    if (_selectedProducto.isNotEmpty) {
      // Specific product selected - use SKU grouping
      name = _selectedProducto;
      groupType = InventoryGroupType.sku;
      sku = widget.item?.sku ?? DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    } else {
      // No product selected - use Categoría as the name/grouping
      // This matches the reference behavior where category-level items
      // display the categoria name with "Agrupación: Categoría · Inventario"
      sku = '';
      groupType = InventoryGroupType.categoria;

      if (_selectedCategoria != 'Todos') {
        name = _selectedCategoria;
      } else if (_selectedSubcategoria != 'Todos') {
        name = _selectedSubcategoria;
        groupType = InventoryGroupType.subcategoria;
      } else if (_selectedFamilia != 'Todos') {
        name = _selectedFamilia;
        groupType = InventoryGroupType.familia;
      } else if (_selectedSubfamilia != 'Todos') {
        name = _selectedSubfamilia;
        groupType = InventoryGroupType.subfamilia;
      } else {
        name = 'Sin clasificación';
      }
    }

    // For editing, keep existing SKU if present
    if (widget.item != null && widget.item!.sku.isNotEmpty) {
      sku = widget.item!.sku;
    }

    final newItem = InventoryLoadItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sku: sku,
      name: name,
      categoria: _selectedCategoria == 'Todos' ? '' : _selectedCategoria,
      subcategoria: _selectedSubcategoria == 'Todos' ? '' : _selectedSubcategoria,
      familia: _selectedFamilia == 'Todos' ? '' : _selectedFamilia,
      subfamilia: _selectedSubfamilia == 'Todos' ? '' : _selectedSubfamilia,
      cajas: cajas,
      unidades: unidades,
      isLoaded: true,
      groupType: groupType,
    );

    widget.onSave(newItem);
    Navigator.pop(context);
  }
}

// Helper function to show the modal
void showInventoryDetailModal(
  BuildContext context, {
  InventoryLoadItem? item,
  required Function(InventoryLoadItem) onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return InventoryDetailModal(
            item: item,
            onSave: onSave,
          );
        },
      ),
    ),
  );
}
