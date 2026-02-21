import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/produto.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class AdminProdutosService {
  static const String _publicEndpoint = '/produtos';
  static const String _adminEndpoint = '/admin/produtos';

  /// ✅ No app ADMIN, deixe true.
  static bool useAdminEndpoints = true;

  static String get _base => useAdminEndpoints ? _adminEndpoint : _publicEndpoint;

  static Exception _apiError(Response res) {
    final data = res.data;
    if (data is Map && data['message'] != null) {
      return Exception(data['message'].toString());
    }
    return Exception('Erro HTTP ${res.statusCode}: ${data?.toString() ?? "sem corpo"}');
  }

  static void _ensureOk(Response res) {
    final code = res.statusCode ?? 0;
    if (code >= 400) throw _apiError(res);
  }

  /// LISTAR
  static Future<List<Produto>> listar() async {
    final res = await ApiClient.dio.get(_base);
    _ensureOk(res);

    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((m) => Produto.fromApi(Map<String, dynamic>.from(m)))
          .toList();
    }

    throw Exception('Resposta inválida da API (esperado lista).');
  }

  /// CRIAR
  static Future<int> criar({
    required String descricao,
    required double preco,
    String? codigoBarras,
    bool ativo = true,

    double? precoCusto,
    double? markup,
    double? margem,

    int? categoriaId,
    String? unidadeMedida,
    double? estoqueAtual,
    double? estoqueMinimo,
  }) async {
    if (!useAdminEndpoints) {
      throw Exception('CRUD exige rotas admin em $_adminEndpoint.');
    }

    final payload = <String, dynamic>{
      'descricao': descricao,
      'preco_venda': preco,
      'ativo': ativo,
      if (codigoBarras != null && codigoBarras.trim().isNotEmpty)
        'codigo_barras': codigoBarras.trim(),
      if (precoCusto != null) 'preco_custo': precoCusto,
      if (markup != null) 'markup': markup,
      if (margem != null) 'margem': margem,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (unidadeMedida != null) 'unidade_medida': unidadeMedida,
      if (estoqueAtual != null) 'estoque_atual': estoqueAtual,
      if (estoqueMinimo != null) 'estoque_minimo': estoqueMinimo,
    };

    final res = await ApiClient.dio.post(_adminEndpoint, data: payload);
    _ensureOk(res);

    final data = res.data;
    if (data is Map && data['id'] != null) {
      return (data['id'] is int) ? data['id'] : int.tryParse('${data['id']}') ?? 0;
    }
    return 0;
  }

  /// ATUALIZAR
  static Future<void> atualizar({
    required int id,
    String? descricao,
    double? preco,
    String? codigoBarras,
    bool? ativo,

    double? precoCusto,
    double? markup,
    double? margem,

    int? categoriaId,
    String? unidadeMedida,
    double? estoqueAtual,
    double? estoqueMinimo,
  }) async {
    if (!useAdminEndpoints) {
      throw Exception('CRUD exige rotas admin em $_adminEndpoint.');
    }

    final payload = <String, dynamic>{};
    if (descricao != null) payload['descricao'] = descricao;
    if (preco != null) payload['preco_venda'] = preco;
    if (codigoBarras != null) payload['codigo_barras'] = codigoBarras;
    if (ativo != null) payload['ativo'] = ativo;

    if (precoCusto != null) payload['preco_custo'] = precoCusto;
    if (markup != null) payload['markup'] = markup;
    if (margem != null) payload['margem'] = margem;

    if (categoriaId != null) payload['categoria_id'] = categoriaId;
    if (unidadeMedida != null) payload['unidade_medida'] = unidadeMedida;
    if (estoqueAtual != null) payload['estoque_atual'] = estoqueAtual;
    if (estoqueMinimo != null) payload['estoque_minimo'] = estoqueMinimo;

    final res = await ApiClient.dio.patch('$_adminEndpoint/$id', data: payload);
    _ensureOk(res);
  }
  /// BUSCAR POR CÓDIGO DE BARRAS (usa GET /admin/produtos?q=XXXX)
  static Future<Produto?> buscarPorCodigoBarras(String codigo) async {
    if (!useAdminEndpoints) return null;

    final q = codigo.trim();
    if (q.isEmpty) return null;

    final res = await ApiClient.dio.get(
      _adminEndpoint,
      queryParameters: {'q': q},
    );
    _ensureOk(res);

    final data = res.data;
    if (data is List && data.isNotEmpty) {
      final m = Map<String, dynamic>.from(data.first as Map);
      return Produto.fromApi(m);
    }
    return null;
  }

  /// REMOVER (soft na UI, mas aqui é DELETE real na sua API)
  static Future<void> removerSoft({required int id}) async {
    if (!useAdminEndpoints) {
      throw Exception('CRUD exige rotas admin em $_adminEndpoint.');
    }

    final res = await ApiClient.dio.delete('$_adminEndpoint/$id');
    _ensureOk(res);
  }
}
