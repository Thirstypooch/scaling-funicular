import 'package:flutter/foundation.dart';

/// Grouping type for inventory items
enum InventoryGroupType {
  sku,
  categoria,
  subcategoria,
  familia,
  subfamilia,
}

extension InventoryGroupTypeExtension on InventoryGroupType {
  String get label {
    switch (this) {
      case InventoryGroupType.sku:
        return 'SKU';
      case InventoryGroupType.categoria:
        return 'Categoría';
      case InventoryGroupType.subcategoria:
        return 'Sub Categoría';
      case InventoryGroupType.familia:
        return 'Familia';
      case InventoryGroupType.subfamilia:
        return 'Sub Familia';
    }
  }
}

/// Represents an item in the inventory load screen
@immutable
class InventoryLoadItem {
  final String id;
  final String sku;
  final String name;
  final String categoria;
  final String subcategoria;
  final String familia;
  final String subfamilia;
  final int cajas;
  final int unidades;
  final bool isLoaded;
  final InventoryGroupType groupType;

  const InventoryLoadItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.categoria,
    required this.subcategoria,
    required this.familia,
    required this.subfamilia,
    required this.cajas,
    required this.unidades,
    this.isLoaded = true,
    this.groupType = InventoryGroupType.sku,
  });

  InventoryLoadItem copyWith({
    String? id,
    String? sku,
    String? name,
    String? categoria,
    String? subcategoria,
    String? familia,
    String? subfamilia,
    int? cajas,
    int? unidades,
    bool? isLoaded,
    InventoryGroupType? groupType,
  }) {
    return InventoryLoadItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      familia: familia ?? this.familia,
      subfamilia: subfamilia ?? this.subfamilia,
      cajas: cajas ?? this.cajas,
      unidades: unidades ?? this.unidades,
      isLoaded: isLoaded ?? this.isLoaded,
      groupType: groupType ?? this.groupType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryLoadItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sku == other.sku &&
          name == other.name &&
          categoria == other.categoria &&
          subcategoria == other.subcategoria &&
          familia == other.familia &&
          subfamilia == other.subfamilia &&
          cajas == other.cajas &&
          unidades == other.unidades &&
          isLoaded == other.isLoaded &&
          groupType == other.groupType;

  @override
  int get hashCode =>
      id.hashCode ^
      sku.hashCode ^
      name.hashCode ^
      categoria.hashCode ^
      subcategoria.hashCode ^
      familia.hashCode ^
      subfamilia.hashCode ^
      cajas.hashCode ^
      unidades.hashCode ^
      isLoaded.hashCode ^
      groupType.hashCode;
}

/// Mock data for inventory load screen
class MockInventoryLoadData {
  static const String clientName = 'Cliente Demo S.A.C.';
  static const String loadDate = '2025-12-16';

  static const List<InventoryLoadItem> items = [
    InventoryLoadItem(
      id: '1',
      sku: '000000218',
      name: 'TRIDENT 5S SANDIA POS 30X18X8.5G',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Trident',
      subfamilia: 'Trident Slab_BSP',
      cajas: 25,
      unidades: 500,
      isLoaded: true,
    ),
    InventoryLoadItem(
      id: '2',
      sku: '000000219',
      name: 'TRIDENT 5S MORA POS 30X18X8.5G',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Trident',
      subfamilia: 'Trident Slab_BSP',
      cajas: 12,
      unidades: 300,
      isLoaded: true,
    ),
    InventoryLoadItem(
      id: '3',
      sku: '000000224',
      name: 'TRIDENT 5S MENTA POS 30X18X8.5G',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Trident',
      subfamilia: 'Trident Slab_BSP',
      cajas: 14,
      unidades: 350,
      isLoaded: true,
    ),
    InventoryLoadItem(
      id: '4',
      sku: '000000225',
      name: 'TRIDENT 5S FRUTAL POS 30X18X8.5G',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Trident',
      subfamilia: 'Trident Slab_BSP',
      cajas: 18,
      unidades: 450,
      isLoaded: true,
    ),
    InventoryLoadItem(
      id: '5',
      sku: '000000230',
      name: 'CHICLETS ADAMS MENTA 100X2.8G',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Chiclets',
      subfamilia: 'Chiclets Adams',
      cajas: 20,
      unidades: 400,
      isLoaded: true,
    ),
  ];

  // Filter options for dropdowns
  static const List<String> categorias = [
    'Todos',
    'Gomas & Caramelos',
    'Chocolates',
    'Galletas',
    'Bebidas',
  ];

  static const List<String> subcategorias = [
    'Todos',
    'Gomas',
    'Caramelos',
    'Tabletas',
    'Barras',
  ];

  static const List<String> familias = [
    'Todos',
    'Trident',
    'Chiclets',
    'Bubbaloo',
    'Clorets',
  ];

  static const List<String> subfamilias = [
    'Todos',
    'Trident Slab_BSP',
    'Chiclets Adams',
    'Bubbaloo Relleno',
    'Clorets Menta',
  ];

  static const List<String> productos = [
    'TRIDENT 5S SANDIA POS 30X18X8.5G',
    'TRIDENT 5S MORA POS 30X18X8.5G',
    'TRIDENT 5S MENTA POS 30X18X8.5G',
    'TRIDENT 5S FRUTAL POS 30X18X8.5G',
    'CHICLETS ADAMS MENTA 100X2.8G',
  ];
}
