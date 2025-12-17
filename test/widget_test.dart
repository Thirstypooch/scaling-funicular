import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockup/app.dart';
import 'package:mockup/bloc/bloc.dart';
import 'package:mockup/repositories/mock_inventory_repository.dart';
import 'package:mockup/widgets/segmented_tab_bar.dart';
import 'package:mockup/screens/inventory_load_screen.dart';

void main() {
  testWidgets('App loads and displays inventory screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Pump and settle to allow BLoC to load data and staggered animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the segmented tab bar is displayed
    expect(find.text('SKU'), findsOneWidget);

    // Verify search field is displayed
    expect(find.byType(TextField), findsOneWidget);

    // Verify summary cards are displayed
    expect(find.text('SellOut total (unid.)'), findsOneWidget);
    expect(find.text('Inventario final (unid.)'), findsOneWidget);
    expect(find.text('SellIn total (unid.)'), findsOneWidget);
  });

  testWidgets('Tab switching works', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Initially on SKU tab
    expect(find.text('Agrupado por SKU'), findsOneWidget);

    // Find the SegmentedTabBar and tap on Familia tab within it
    final tabBar = find.byType(SegmentedTabBar);
    final familiaText = find.descendant(
      of: tabBar,
      matching: find.text('Familia'),
    );
    await tester.tap(familiaText);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify switched to familia
    expect(find.text('Agrupado por familia'), findsOneWidget);
  });

  test('BLoC emits correct states', () async {
    final repository = MockInventoryRepository();
    final bloc = InventoryBloc(repository: repository);

    // Initial state
    expect(bloc.state.status, InventoryStatus.initial);

    // Load inventory
    bloc.add(const LoadInventory());

    // Wait for state to update
    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<InventoryState>((s) => s.status == InventoryStatus.loading),
        predicate<InventoryState>((s) => s.status == InventoryStatus.loaded && s.items.isNotEmpty),
      ]),
    );

    await bloc.close();
  });

  testWidgets('Navigation to inventory load screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify FAB icon is displayed (collapsed state)
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Tap the FAB to expand it
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // Verify FAB is now expanded with text
    expect(find.text('Cargar inventario'), findsOneWidget);

    // Tap again to navigate
    await tester.tap(find.text('Cargar inventario'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify we're on the inventory load screen
    expect(find.text('Carga de inventario'), findsOneWidget);
    expect(find.text('Cliente Demo S.A.C.'), findsOneWidget);
    expect(find.text('Agregar producto'), findsOneWidget);
  });

  testWidgets('Inventory load screen displays items', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const InventoryLoadScreen(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify header
    expect(find.text('Carga de inventario'), findsOneWidget);

    // Verify client info
    expect(find.text('Cliente Demo S.A.C.'), findsOneWidget);
    expect(find.text('2025-12-16'), findsOneWidget);

    // Verify add button
    expect(find.text('Agregar producto'), findsOneWidget);

    // Verify items are displayed (check subtitle and category chips)
    expect(find.textContaining('Inventario para promo Trident'), findsWidgets);
    expect(find.text('Inventario cargado'), findsWidgets);
  });
}
