import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import 'repositories/inventory_repository.dart';
import 'repositories/mock_inventory_repository.dart';
import 'screens/inventory_screen.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  /// The repository to use for data
  /// Defaults to MockInventoryRepository
  final InventoryRepository? repository;

  /// Whether to use streaming (real-time updates) or one-time loading
  final bool useStreaming;

  const App({
    super.key,
    this.repository,
    this.useStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppTheme.scaffoldBackground,
        fontFamily: 'Roboto',
      ),
      home: RepositoryProvider<InventoryRepository>(
        create: (_) => repository ?? MockInventoryRepository(),
        child: BlocProvider(
          create: (context) => InventoryBloc(
            repository: context.read<InventoryRepository>(),
          ),
          child: InventoryScreen(useStreaming: useStreaming),
        ),
      ),
    );
  }
}
