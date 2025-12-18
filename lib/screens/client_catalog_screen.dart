import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/client_card.dart';
import '../widgets/custom_pull_to_refresh.dart';

class ClientCatalogScreen extends StatefulWidget {
  const ClientCatalogScreen({super.key});

  @override
  State<ClientCatalogScreen> createState() => _ClientCatalogScreenState();
}

class _ClientCatalogScreenState extends State<ClientCatalogScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<ClientApiItem> _allClients = [];
  List<ClientApiItem> _displayedClients = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';
  Timer? _searchDebounce;

  // Pagination
  static const int _pageSize = 15;
  int _currentPage = 0;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadClients(isInitialLoad: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    _apiService.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreClients();
    }
  }

  Future<void> _loadClients({bool isInitialLoad = false}) async {
    // Only show full loading state on initial load (when we have no data)
    if (isInitialLoad || _allClients.isEmpty) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final response = await _apiService.getClientCatalog();
      setState(() {
        _allClients = response.data;
        _currentPage = 0;
        _applyFiltersAndPaginate();
        _isLoading = false;
      });
    } catch (e) {
      // Only show error if we have no data to display
      if (_allClients.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      } else {
        // Silently fail if we already have data - keep showing existing data
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFiltersAndPaginate() {
    List<ClientApiItem> filtered = _allClients;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = _allClients.where((client) {
        return client.nombre.toLowerCase().contains(query) ||
            client.razonSocial.toLowerCase().contains(query) ||
            client.ruc.toLowerCase().contains(query) ||
            client.codigoErp.toLowerCase().contains(query) ||
            client.direccion.toLowerCase().contains(query) ||
            client.coloniaNombre.toLowerCase().contains(query) ||
            client.giroCliente.toLowerCase().contains(query);
      }).toList();
    }

    // Apply pagination
    final endIndex = (_currentPage + 1) * _pageSize;
    _displayedClients = filtered.take(endIndex).toList();
    _hasMoreData = endIndex < filtered.length;
  }

  Future<void> _loadMoreClients() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _currentPage++;
      _applyFiltersAndPaginate();
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadClients();
    setState(() => _isRefreshing = false);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        _searchQuery = value;
        _currentPage = 0;
        _applyFiltersAndPaginate();
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _currentPage = 0;
      _applyFiltersAndPaginate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildHeader(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Catálogo de Clientes',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
          onPressed: () {
            // TODO: Implement filters
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Buscar cliente, RUC, dirección...',
            hintStyle: AppTheme.searchHint,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.textGray.withValues(alpha: 0.6),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textGray.withValues(alpha: 0.6),
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalFiltered = _searchQuery.isNotEmpty
        ? _allClients.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.nombre.toLowerCase().contains(query) ||
                c.razonSocial.toLowerCase().contains(query) ||
                c.ruc.toLowerCase().contains(query) ||
                c.codigoErp.toLowerCase().contains(query) ||
                c.direccion.toLowerCase().contains(query) ||
                c.coloniaNombre.toLowerCase().contains(query) ||
                c.giroCliente.toLowerCase().contains(query);
          }).length
        : _allClients.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Flexible(
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Resultados para "$_searchQuery"'
                  : 'Todos los clientes',
              style: AppTheme.groupHeader,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$totalFiltered',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          // Show subtle refresh indicator when refreshing in background
          if (_isRefreshing) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_displayedClients.isEmpty) {
      return _buildEmptyState();
    }

    return CustomPullToRefresh(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _displayedClients.length + (_hasMoreData ? 1 : 1),
        itemBuilder: (context, index) {
          if (index < _displayedClients.length) {
            return ClientCard(
              client: _displayedClients[index],
              onTap: () => _showClientDetails(_displayedClients[index]),
            );
          }

          // End indicator
          if (!_hasMoreData) {
            return _buildEndMessage();
          }

          // Loading more indicator
          return _buildLoadingMoreIndicator();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando clientes...',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar clientes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGrayDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadClients,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: AppTheme.textGray.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron clientes'
                : 'Sin clientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGrayDark,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildEndMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: AppTheme.textGray.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'Has visto todos los clientes',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textGray.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClientDetails(ClientApiItem client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClientDetailSheet(client: client),
    );
  }
}

class _ClientDetailSheet extends StatelessWidget {
  final ClientApiItem client;

  const _ClientDetailSheet({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        color: AppTheme.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textGrayDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: client.activo
                                  ? AppTheme.accentGreen.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              client.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: client.activo
                                    ? AppTheme.accentGreen
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Details
                _buildDetailItem(
                  Icons.badge_outlined,
                  'RUC',
                  client.ruc,
                ),
                _buildDetailItem(
                  Icons.business_outlined,
                  'Razón Social',
                  client.razonSocial,
                ),
                _buildDetailItem(
                  Icons.store_outlined,
                  'Giro de Cliente',
                  client.giroCliente,
                ),
                _buildDetailItem(
                  Icons.tag_rounded,
                  'Código ERP',
                  client.codigoErp,
                ),
                _buildDetailItem(
                  Icons.fingerprint_rounded,
                  'ID Cliente',
                  client.id,
                ),
                _buildDetailItem(
                  Icons.apartment_rounded,
                  'Compañía',
                  client.compania,
                ),
                _buildDetailItem(
                  Icons.storefront_rounded,
                  'Sucursal',
                  client.sucursal,
                ),

                const Divider(height: 32),

                // Location section
                Text(
                  'Ubicación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrayDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  Icons.location_on_outlined,
                  'Dirección',
                  client.direccion,
                ),
                _buildDetailItem(
                  Icons.place_outlined,
                  'Distrito',
                  client.coloniaNombre,
                ),
                if (client.latitud != null && client.longitud != null)
                  _buildDetailItem(
                    Icons.gps_fixed_rounded,
                    'Coordenadas',
                    '${client.latitud}, ${client.longitud}',
                  ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Open in maps
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Ver en mapa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: BorderSide(color: AppTheme.primaryBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Select client for inventory
                        },
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Cargar inventario'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.textGray,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textGrayDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
