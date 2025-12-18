import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_pull_to_refresh.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<ProductApiItem> _allProducts = [];
  List<ProductApiItem> _displayedProducts = [];
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
    _loadProducts(isInitialLoad: true);
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
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts({bool isInitialLoad = false}) async {
    // Only show full loading state on initial load (when we have no data)
    if (isInitialLoad || _allProducts.isEmpty) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final response = await _apiService.getProductCatalog();
      setState(() {
        _allProducts = response.data;
        _currentPage = 0;
        _applyFiltersAndPaginate();
        _isLoading = false;
      });
    } catch (e) {
      // Only show error if we have no data to display
      if (_allProducts.isEmpty) {
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
    List<ProductApiItem> filtered = _allProducts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = _allProducts.where((product) {
        return product.nombre.toLowerCase().contains(query) ||
            product.sku.toLowerCase().contains(query) ||
            product.codigoErp.toLowerCase().contains(query) ||
            product.marca.toLowerCase().contains(query) ||
            product.categoria.toLowerCase().contains(query) ||
            product.subcategoria.toLowerCase().contains(query) ||
            product.familia.toLowerCase().contains(query) ||
            product.subFamilia.toLowerCase().contains(query);
      }).toList();
    }

    // Apply pagination
    final endIndex = (_currentPage + 1) * _pageSize;
    _displayedProducts = filtered.take(endIndex).toList();
    _hasMoreData = endIndex < filtered.length;
  }

  Future<void> _loadMoreProducts() async {
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
    await _loadProducts();
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
        'Catálogo de Productos',
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
            hintText: 'Buscar producto, SKU, marca...',
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
        ? _allProducts.where((p) {
            final query = _searchQuery.toLowerCase();
            return p.nombre.toLowerCase().contains(query) ||
                p.sku.toLowerCase().contains(query) ||
                p.codigoErp.toLowerCase().contains(query) ||
                p.marca.toLowerCase().contains(query) ||
                p.categoria.toLowerCase().contains(query) ||
                p.subcategoria.toLowerCase().contains(query) ||
                p.familia.toLowerCase().contains(query) ||
                p.subFamilia.toLowerCase().contains(query);
          }).length
        : _allProducts.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Flexible(
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Resultados para "$_searchQuery"'
                  : 'Todos los productos',
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

    if (_displayedProducts.isEmpty) {
      return _buildEmptyState();
    }

    return CustomPullToRefresh(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _displayedProducts.length + (_hasMoreData ? 1 : 1),
        itemBuilder: (context, index) {
          if (index < _displayedProducts.length) {
            return ProductCard(
              product: _displayedProducts[index],
              onTap: () => _showProductDetails(_displayedProducts[index]),
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
            'Cargando productos...',
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
              'Error al cargar productos',
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
              onPressed: () => _loadProducts(isInitialLoad: true),
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
            Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.textGray.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron productos'
                : 'Sin productos',
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
              'Has visto todos los productos',
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

  void _showProductDetails(ProductApiItem product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(product: product),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final ProductApiItem product;

  const _ProductDetailSheet({required this.product});

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
                        Icons.inventory_2_rounded,
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
                            product.nombre,
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
                              color: product.activo
                                  ? AppTheme.accentGreen.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: product.activo
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

                // Identification
                Text(
                  'Identificación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrayDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  Icons.qr_code_rounded,
                  'SKU',
                  product.sku,
                ),
                _buildDetailItem(
                  Icons.tag_rounded,
                  'Código ERP',
                  product.codigoErp,
                ),
                _buildDetailItem(
                  Icons.fingerprint_rounded,
                  'ID Producto',
                  product.id,
                ),
                _buildDetailItem(
                  Icons.sell_rounded,
                  'Marca',
                  product.marca,
                ),

                const Divider(height: 32),

                // Category hierarchy
                Text(
                  'Clasificación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrayDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  Icons.category_rounded,
                  'Categoría',
                  product.categoria,
                ),
                _buildDetailItem(
                  Icons.subdirectory_arrow_right_rounded,
                  'Subcategoría',
                  product.subcategoria,
                ),
                _buildDetailItem(
                  Icons.family_restroom_rounded,
                  'Familia',
                  product.familia,
                ),
                _buildDetailItem(
                  Icons.folder_outlined,
                  'Subfamilia',
                  product.subFamilia.isNotEmpty ? product.subFamilia : 'Sin subfamilia',
                ),

                if (product.descripcionCorta != null || product.descripcionAmpliada != null) ...[
                  const Divider(height: 32),
                  Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGrayDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (product.descripcionCorta != null)
                    _buildDetailItem(
                      Icons.short_text_rounded,
                      'Corta',
                      product.descripcionCorta!,
                    ),
                  if (product.descripcionAmpliada != null)
                    _buildDetailItem(
                      Icons.article_rounded,
                      'Ampliada',
                      product.descripcionAmpliada!,
                    ),
                ],

                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Select product for inventory load
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Cargar inventario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
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
