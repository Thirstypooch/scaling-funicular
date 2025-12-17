import 'tab_type.dart';

class InventoryItem {
  final String id;
  final String name;
  final String? categoria;
  final String? subcategoria;
  final String? familia;
  final String? subfamilia;
  final int registros;
  final int skus;
  final int inventory;
  final int sellIn;
  final int sellOut;
  final int initialInventory;
  final int position;
  final String timestamp;
  final bool hasSales;

  const InventoryItem({
    required this.id,
    required this.name,
    this.categoria,
    this.subcategoria,
    this.familia,
    this.subfamilia,
    required this.registros,
    required this.skus,
    required this.inventory,
    required this.sellIn,
    required this.sellOut,
    required this.initialInventory,
    required this.position,
    required this.timestamp,
    this.hasSales = true,
  });

  String getDisplayTitle(TabType tabType) {
    switch (tabType) {
      case TabType.sku:
        return '$id — $name';
      case TabType.categoria:
        return categoria ?? name;
      case TabType.subcategoria:
        return subcategoria ?? name;
      case TabType.familia:
        return familia ?? name;
    }
  }

  String getGroupTypeLabel(TabType tabType) {
    switch (tabType) {
      case TabType.sku:
        return 'SKU';
      case TabType.categoria:
        return 'CATEGORIA';
      case TabType.subcategoria:
        return 'SUBCATEGORIA';
      case TabType.familia:
        return 'FAMILIA';
    }
  }
}

class MockData {
  static const List<InventoryItem> skuItems = [
    InventoryItem(
      id: '99998755',
      name: 'MISCELANEO',
      categoria: 'MISCELANEOS',
      subcategoria: 'Miscelaneos',
      familia: 'MISCELANEOS',
      registros: 12,
      skus: 1,
      inventory: 1570,
      sellIn: 1227,
      sellOut: 1137,
      initialInventory: 1480,
      position: 1,
      timestamp: '12:05 p. m.',
    ),
    InventoryItem(
      id: '76222017702700',
      name: 'Bubbaloo Banana 5,1g X Display x 70 un.',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Trident',
      registros: 12,
      skus: 1,
      inventory: 1541,
      sellIn: 1045,
      sellOut: 1047,
      initialInventory: 1543,
      position: 2,
      timestamp: '12:05 p. m.',
    ),
    InventoryItem(
      id: '76222014628600',
      name: 'Oreo Original Rollo 54g X 1 un.',
      categoria: 'Galletas',
      subcategoria: 'Galletas',
      familia: 'Oreo',
      registros: 12,
      skus: 1,
      inventory: 2046,
      sellIn: 1179,
      sellOut: 780,
      initialInventory: 1647,
      position: 3,
      timestamp: '12:05 p. m.',
    ),
    InventoryItem(
      id: '76222016929500',
      name: 'Clight sabor Fresa 14g X Display x 15 un.',
      categoria: 'Bebidas & Postres',
      subcategoria: 'Bebidas',
      familia: 'Clight',
      registros: 12,
      skus: 1,
      inventory: 2157,
      sellIn: 1081,
      sellOut: 718,
      initialInventory: 1794,
      position: 4,
      timestamp: '12:05 p. m.',
    ),
    InventoryItem(
      id: '750610561606604',
      name: 'Trident 18s Yerbabuena 30,6g X Display x 12 un.',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Trident',
      registros: 12,
      skus: 1,
      inventory: 1948,
      sellIn: 1287,
      sellOut: 701,
      initialInventory: 1362,
      position: 5,
      timestamp: '12:05 p. m.',
    ),
    InventoryItem(
      id: '76222013899900',
      name: 'Ritz Queso 30g X Display x 6 un.',
      categoria: 'Galletas',
      subcategoria: 'Galletas',
      familia: 'Ritz',
      registros: 12,
      skus: 1,
      inventory: 1438,
      sellIn: 877,
      sellOut: 612,
      initialInventory: 1173,
      position: 6,
      timestamp: '12:05 p. m.',
    ),
    InventoryItem(
      id: '125466712203',
      name: 'Trident Splash Fresa Limón X Display x 18 un.',
      categoria: 'Gomas & Caramelos',
      subcategoria: 'Gomas',
      familia: 'Trident',
      registros: 12,
      skus: 1,
      inventory: 2383,
      sellIn: 1211,
      sellOut: 607,
      initialInventory: 1779,
      position: 7,
      timestamp: '12:05 p. m.',
    ),
  ];

  static const List<InventoryItem> categoriaItems = [
    InventoryItem(
      id: 'cat1',
      name: 'Gomas & Caramelos',
      categoria: 'Gomas & Caramelos',
      registros: 36,
      skus: 3,
      inventory: 5872,
      sellIn: 3543,
      sellOut: 2355,
      initialInventory: 4684,
      position: 1,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'cat2',
      name: 'Galletas',
      categoria: 'Galletas',
      registros: 24,
      skus: 2,
      inventory: 3484,
      sellIn: 2056,
      sellOut: 1392,
      initialInventory: 2820,
      position: 2,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'cat3',
      name: 'MISCELANEOS',
      categoria: 'MISCELANEOS',
      registros: 12,
      skus: 1,
      inventory: 1570,
      sellIn: 1227,
      sellOut: 1137,
      initialInventory: 1480,
      position: 3,
      timestamp: '12:10 p. m.',
    ),
    InventoryItem(
      id: 'cat4',
      name: 'Bebidas & Postres',
      categoria: 'Bebidas & Postres',
      registros: 12,
      skus: 1,
      inventory: 2157,
      sellIn: 1081,
      sellOut: 718,
      initialInventory: 1794,
      position: 4,
      timestamp: '12:10 p. m.',
    ),
  ];

  static const List<InventoryItem> subcategoriaItems = [
    InventoryItem(
      id: 'sub1',
      name: 'Gomas',
      subcategoria: 'Gomas',
      registros: 36,
      skus: 3,
      inventory: 5872,
      sellIn: 3543,
      sellOut: 2355,
      initialInventory: 4684,
      position: 1,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'sub2',
      name: 'Galletas',
      subcategoria: 'Galletas',
      registros: 24,
      skus: 2,
      inventory: 3484,
      sellIn: 2056,
      sellOut: 1392,
      initialInventory: 2820,
      position: 2,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'sub3',
      name: 'Bebidas',
      subcategoria: 'Bebidas',
      registros: 12,
      skus: 1,
      inventory: 2157,
      sellIn: 1081,
      sellOut: 718,
      initialInventory: 1794,
      position: 3,
      timestamp: '12:11 p. m.',
    ),
  ];

  static const List<InventoryItem> familiaItems = [
    InventoryItem(
      id: 'fam1',
      name: 'Trident',
      familia: 'Trident',
      registros: 24,
      skus: 2,
      inventory: 4331,
      sellIn: 2498,
      sellOut: 1308,
      initialInventory: 3141,
      position: 1,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'fam2',
      name: 'MISCELANEOS',
      familia: 'MISCELANEOS',
      registros: 12,
      skus: 1,
      inventory: 1570,
      sellIn: 1227,
      sellOut: 1137,
      initialInventory: 1480,
      position: 2,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'fam3',
      name: 'Oreo',
      familia: 'Oreo',
      registros: 12,
      skus: 1,
      inventory: 2046,
      sellIn: 1179,
      sellOut: 780,
      initialInventory: 1647,
      position: 3,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'fam4',
      name: 'Clight',
      familia: 'Clight',
      registros: 12,
      skus: 1,
      inventory: 2157,
      sellIn: 1081,
      sellOut: 718,
      initialInventory: 1794,
      position: 4,
      timestamp: '12:08 p. m.',
    ),
    InventoryItem(
      id: 'fam5',
      name: 'Ritz',
      familia: 'Ritz',
      registros: 12,
      skus: 1,
      inventory: 1438,
      sellIn: 877,
      sellOut: 612,
      initialInventory: 1173,
      position: 5,
      timestamp: '12:08 p. m.',
    ),
  ];

  static List<InventoryItem> getItemsForTab(TabType tabType) {
    switch (tabType) {
      case TabType.sku:
        return _generateExpandedSkuItems();
      case TabType.categoria:
        return _generateExpandedCategoriaItems();
      case TabType.subcategoria:
        return _generateExpandedSubcategoriaItems();
      case TabType.familia:
        return _generateExpandedFamiliaItems();
    }
  }

  // Generate 50+ SKU items for infinite scroll demo
  static List<InventoryItem> _generateExpandedSkuItems() {
    final List<InventoryItem> expanded = [];
    final baseItems = skuItems;

    // Add original items
    expanded.addAll(baseItems);

    // Generate more items based on patterns
    final names = [
      'Trident Menta 18s',
      'Bubbaloo Fresa 5g',
      'Oreo Golden',
      'Chips Ahoy Original',
      'Clight Naranja',
      'Trident Splash Menta',
      'Chiclets Adams',
      'Halls Menta',
      'Tang Naranja',
      'Philadelphia Original',
      'Milka Oreo',
      'Toblerone Dark',
      'Cadbury Dairy Milk',
      'Club Social Original',
      'Belvita Breakfast',
    ];

    final categories = ['Gomas & Caramelos', 'Galletas', 'Bebidas & Postres', 'MISCELANEOS'];
    final subcats = ['Gomas', 'Galletas', 'Bebidas', 'Miscelaneos'];
    final familias = ['Trident', 'Oreo', 'Clight', 'Ritz', 'MISCELANEOS'];

    for (int i = 0; i < 45; i++) {
      final catIndex = i % categories.length;
      final nameIndex = i % names.length;
      expanded.add(InventoryItem(
        id: '${76222000000000 + i * 1000}',
        name: '${names[nameIndex]} X Display x ${(i % 12) + 6} un.',
        categoria: categories[catIndex],
        subcategoria: subcats[catIndex],
        familia: familias[i % familias.length],
        registros: 8 + (i % 8),
        skus: 1,
        inventory: 800 + (i * 47) % 2000,
        sellIn: 400 + (i * 31) % 1500,
        sellOut: 300 + (i * 23) % 1200,
        initialInventory: 700 + (i * 41) % 1800,
        position: baseItems.length + i + 1,
        timestamp: '${10 + (i % 4)}:${(i * 5) % 60 < 10 ? '0' : ''}${(i * 5) % 60} ${i % 2 == 0 ? 'a' : 'p'}. m.',
      ));
    }

    return expanded;
  }

  // Generate 20+ categoria items
  static List<InventoryItem> _generateExpandedCategoriaItems() {
    final List<InventoryItem> expanded = List.from(categoriaItems);

    final extraCategories = [
      'Chocolates',
      'Snacks Salados',
      'Cereales',
      'Lácteos',
      'Helados',
      'Panadería',
      'Confitería',
      'Bebidas Energéticas',
      'Productos Light',
      'Importados',
      'Productos Premium',
      'Línea Infantil',
      'Productos Dietéticos',
      'Snacks Saludables',
      'Línea Gourmet',
    ];

    for (int i = 0; i < extraCategories.length; i++) {
      expanded.add(InventoryItem(
        id: 'cat${categoriaItems.length + i + 1}',
        name: extraCategories[i],
        categoria: extraCategories[i],
        registros: 10 + (i * 3) % 30,
        skus: 2 + i % 5,
        inventory: 2000 + (i * 500) % 5000,
        sellIn: 1000 + (i * 300) % 3000,
        sellOut: 800 + (i * 200) % 2500,
        initialInventory: 1800 + (i * 400) % 4000,
        position: categoriaItems.length + i + 1,
        timestamp: '${11 + (i % 3)}:${(i * 7) % 60 < 10 ? '0' : ''}${(i * 7) % 60} p. m.',
      ));
    }

    return expanded;
  }

  // Generate 15+ subcategoria items
  static List<InventoryItem> _generateExpandedSubcategoriaItems() {
    final List<InventoryItem> expanded = List.from(subcategoriaItems);

    final extraSubcats = [
      'Chocolates con Leche',
      'Chocolates Oscuros',
      'Papas Fritas',
      'Nachos',
      'Cereales Azucarados',
      'Cereales Integrales',
      'Yogures',
      'Quesos',
      'Helados de Crema',
      'Paletas',
      'Pan Dulce',
      'Pan Integral',
    ];

    for (int i = 0; i < extraSubcats.length; i++) {
      expanded.add(InventoryItem(
        id: 'sub${subcategoriaItems.length + i + 1}',
        name: extraSubcats[i],
        subcategoria: extraSubcats[i],
        registros: 8 + (i * 2) % 20,
        skus: 1 + i % 4,
        inventory: 1500 + (i * 400) % 4000,
        sellIn: 800 + (i * 250) % 2500,
        sellOut: 600 + (i * 180) % 2000,
        initialInventory: 1400 + (i * 350) % 3500,
        position: subcategoriaItems.length + i + 1,
        timestamp: '${10 + (i % 4)}:${(i * 8) % 60 < 10 ? '0' : ''}${(i * 8) % 60} p. m.',
      ));
    }

    return expanded;
  }

  // Generate 20+ familia items
  static List<InventoryItem> _generateExpandedFamiliaItems() {
    final List<InventoryItem> expanded = List.from(familiaItems);

    final extraFamilias = [
      'Milka',
      'Toblerone',
      'Cadbury',
      'Chips Ahoy',
      'Club Social',
      'Belvita',
      'Tang',
      'Philadelphia',
      'Halls',
      'Chiclets',
      'Bubbaloo',
      'Dentyne',
      'Stride',
      'Lacta',
      'Bis',
    ];

    for (int i = 0; i < extraFamilias.length; i++) {
      expanded.add(InventoryItem(
        id: 'fam${familiaItems.length + i + 1}',
        name: extraFamilias[i],
        familia: extraFamilias[i],
        registros: 10 + (i * 2) % 25,
        skus: 1 + i % 3,
        inventory: 1800 + (i * 450) % 4500,
        sellIn: 900 + (i * 280) % 2800,
        sellOut: 700 + (i * 200) % 2200,
        initialInventory: 1600 + (i * 380) % 4000,
        position: familiaItems.length + i + 1,
        timestamp: '${10 + (i % 5)}:${(i * 6) % 60 < 10 ? '0' : ''}${(i * 6) % 60} p. m.',
      ));
    }

    return expanded;
  }

  static const int totalSellOut = 5602;
  static const int totalInventory = 13083;
  static const int totalSellIn = 7907;
  static const int totalRegistros = 84;
  static const int totalSkus = 7;
  static const String inventoryDate = '2025-12-16';
}
