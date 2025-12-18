import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrl = 'https://mdlz.geosales.cloud/monitoreoservicios/monitor/sdk/index.php';
  static const String origen = 'GEO001';
  static const String token = '0987654321jlglhjgljhkhgkjghkgd7it7f976f7gf854s754';
  static const String tipoRespuesta = 'JSON';
  static const String cia = '45';
  static const String idSucursal = '44';
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final int? recordCount;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.recordCount,
  });
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _baseParams => {
    'origen': ApiConfig.origen,
    'token': ApiConfig.token,
    'Tipo_Respuesta': ApiConfig.tipoRespuesta,
    'cia': ApiConfig.cia,
  };

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, String> params) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    final allParams = {..._baseParams, ...params};

    try {
      final response = await _client.post(
        uri,
        body: allParams,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  List<T> _parseResponse<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final log = json['log'] as List?;
    if (log == null || log.isEmpty) {
      return [];
    }

    final firstLog = log[0] as Map<String, dynamic>;
    final result = firstLog['result'];

    if (result == 0) {
      final datos = firstLog['datos'] as Map<String, dynamic>?;
      final errorMsg = datos?['txt_res'] ?? firstLog['result_descripcion'] ?? 'Unknown error';
      throw ApiException(errorMsg);
    }

    final datos = firstLog['datos'] as Map<String, dynamic>?;
    final dataList = datos?['datos'] as List? ?? [];

    return dataList
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get inventory catalog
  Future<ApiResponse<InventoryApiItem>> getInventoryCatalog({
    String? segmentacion,
    String? codigoNombre,
  }) async {
    final params = <String, String>{};
    if (segmentacion != null) params['segmentacion'] = segmentacion;
    if (codigoNombre != null) params['codigo_nombre'] = codigoNombre;

    final json = await _post('catalogoInventarioClienteIndirecto', params);
    final items = _parseResponse(json, InventoryApiItem.fromJson);

    return ApiResponse(
      success: true,
      message: 'OK',
      data: items,
      recordCount: items.length,
    );
  }

  /// Get product catalog
  Future<ApiResponse<ProductApiItem>> getProductCatalog({
    String? segmentacion,
  }) async {
    final params = <String, String>{
      'id_sucursal': ApiConfig.idSucursal,
    };
    if (segmentacion != null) params['segmentacion'] = segmentacion;

    final json = await _post('catalogoProductoNew', params);
    final items = _parseResponse(json, ProductApiItem.fromJson);

    return ApiResponse(
      success: true,
      message: 'OK',
      data: items,
      recordCount: items.length,
    );
  }

  /// Get client catalog
  /// [cli] is required - it's the route/segment ID (default: 2201)
  Future<ApiResponse<ClientApiItem>> getClientCatalog({
    String cli = '2201', // Default route ID
    String? codigoNombre,
  }) async {
    final params = <String, String>{
      'cli': cli,
    };
    if (codigoNombre != null) params['codigo_nombre'] = codigoNombre;

    final json = await _post('catalogoClienteNew', params);
    final items = _parseResponse(json, ClientApiItem.fromJson);

    return ApiResponse(
      success: true,
      message: 'OK',
      data: items,
      recordCount: items.length,
    );
  }

  /// Create/Update/Delete inventory record
  Future<ApiResponse<void>> saveInventory({
    required String action, // INSERT, UPDATE, DELETE
    required String clientId,
    required String categoria,
    required int existenciaUnidades,
    String? idRegistro,
    String? subcategoria,
    String? familia,
    String? subfamilia,
    int? existenciaCajas,
  }) async {
    final params = <String, String>{
      'action': action,
      'cli': clientId,
      'categoria': categoria,
      'existencia_unidades': existenciaUnidades.toString(),
    };

    if (idRegistro != null) params['idRegistro'] = idRegistro;
    if (subcategoria != null) params['subcategoria'] = subcategoria;
    if (familia != null) params['familia'] = familia;
    if (subfamilia != null) params['subfamilia'] = subfamilia;
    if (existenciaCajas != null) params['existencia_cajas'] = existenciaCajas.toString();

    final json = await _post('cargarInventarioClienteIndirecto', params);
    final log = json['log'] as List?;

    if (log != null && log.isNotEmpty) {
      final firstLog = log[0] as Map<String, dynamic>;
      final result = firstLog['result'];
      if (result == 0) {
        final datos = firstLog['datos'] as Map<String, dynamic>?;
        throw ApiException(datos?['txt_res'] ?? 'Operation failed');
      }
    }

    return ApiResponse(
      success: true,
      message: 'OK',
      data: [],
    );
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

// API Response Models

class InventoryApiItem {
  final String id;
  final String? compania;
  final String? sucursal;
  final String? cliente;
  final String categoria;
  final String subcategoria;
  final String familia;
  final String subfamilia;
  final String? producto;
  final int existenciaUnidades;
  final int existenciaCajas;
  final String fechaRegistro;
  final String? serie;
  final String? codigoBarras;
  final String? codigoQr;

  InventoryApiItem({
    required this.id,
    this.compania,
    this.sucursal,
    this.cliente,
    required this.categoria,
    required this.subcategoria,
    required this.familia,
    required this.subfamilia,
    this.producto,
    required this.existenciaUnidades,
    required this.existenciaCajas,
    required this.fechaRegistro,
    this.serie,
    this.codigoBarras,
    this.codigoQr,
  });

  factory InventoryApiItem.fromJson(Map<String, dynamic> json) {
    return InventoryApiItem(
      id: json['id_inventario_cliente_indirecto']?.toString() ?? '',
      compania: json['compania'],
      sucursal: json['sucursal'],
      cliente: json['cliente'],
      categoria: json['categoria'] ?? '',
      subcategoria: json['subcategoria'] ?? '',
      familia: json['familia'] ?? '',
      subfamilia: json['subfamilia'] ?? '',
      producto: json['producto'],
      existenciaUnidades: int.tryParse(json['existencia_unidades']?.toString() ?? '0') ?? 0,
      existenciaCajas: int.tryParse(json['existencia_cajas']?.toString() ?? '0') ?? 0,
      fechaRegistro: json['fecha_registro'] ?? '',
      serie: json['serie'],
      codigoBarras: json['codigo_barras'],
      codigoQr: json['codigo_qr'],
    );
  }
}

class ProductApiItem {
  final String id;
  final String codigoErp;
  final String sku;
  final String nombre;
  final String? descripcionCorta;
  final String? descripcionAmpliada;
  final String marca;
  final String categoria;
  final String subcategoria;
  final String familia;
  final String subFamilia;
  final bool activo;

  ProductApiItem({
    required this.id,
    required this.codigoErp,
    required this.sku,
    required this.nombre,
    this.descripcionCorta,
    this.descripcionAmpliada,
    required this.marca,
    required this.categoria,
    required this.subcategoria,
    required this.familia,
    required this.subFamilia,
    required this.activo,
  });

  factory ProductApiItem.fromJson(Map<String, dynamic> json) {
    return ProductApiItem(
      id: json['id_producto']?.toString() ?? '',
      codigoErp: json['codigo_erp'] ?? '',
      sku: json['sku'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcionCorta: json['descripcion_corta'],
      descripcionAmpliada: json['descripcion_ampliada'],
      marca: json['marca'] ?? '',
      categoria: json['categoria'] ?? '',
      subcategoria: json['subcategoria'] ?? '',
      familia: json['familia'] ?? '',
      subFamilia: json['sub_familia'] ?? '',
      activo: json['activo'] == '1',
    );
  }
}

class ClientApiItem {
  final String id;
  final String codigoErp;
  final String nombre;
  final String razonSocial;
  final String ruc;
  final String giroCliente;
  final double? latitud;
  final double? longitud;
  final String direccion;
  final String coloniaNombre;
  final String compania;
  final String sucursal;
  final bool activo;

  ClientApiItem({
    required this.id,
    required this.codigoErp,
    required this.nombre,
    required this.razonSocial,
    required this.ruc,
    required this.giroCliente,
    this.latitud,
    this.longitud,
    required this.direccion,
    required this.coloniaNombre,
    required this.compania,
    required this.sucursal,
    required this.activo,
  });

  factory ClientApiItem.fromJson(Map<String, dynamic> json) {
    return ClientApiItem(
      id: json['id_cliente']?.toString() ?? '',
      codigoErp: json['codigo_erp'] ?? '',
      nombre: json['nombre'] ?? '',
      razonSocial: json['razon_social'] ?? '',
      ruc: json['ruc'] ?? '',
      giroCliente: json['giro_cliente'] ?? '',
      latitud: double.tryParse(json['latitud']?.toString() ?? ''),
      longitud: double.tryParse(json['longitud']?.toString() ?? ''),
      direccion: json['direccion'] ?? '',
      coloniaNombre: json['colonia_nombre'] ?? '',
      compania: json['compania'] ?? '',
      sucursal: json['sucursal'] ?? '',
      activo: json['activo'] == '1',
    );
  }
}
