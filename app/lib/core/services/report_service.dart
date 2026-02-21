import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class DashboardData {
  final KpiBlock hoje;
  final KpiBlock semana;
  final KpiBlock mes;
  final double ticketMedio;
  final List<TopProduto> topProdutos;
  final int alertaEstoque;

  DashboardData({
    required this.hoje,
    required this.semana,
    required this.mes,
    required this.ticketMedio,
    required this.topProdutos,
    required this.alertaEstoque,
  });

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final hoje = json['hoje'] as Map<String, dynamic>? ?? {};
    final semana = json['semana'] as Map<String, dynamic>? ?? {};
    final mes = json['mes'] as Map<String, dynamic>? ?? {};

    return DashboardData(
      hoje: KpiBlock(qtd: _i(hoje['qtd']), receita: _d(hoje['receita'])),
      semana: KpiBlock(qtd: _i(semana['qtd']), receita: _d(semana['receita'])),
      mes: KpiBlock(qtd: _i(mes['qtd']), receita: _d(mes['receita'])),
      ticketMedio: _d(json['ticketMedio']),
      topProdutos: (json['topProdutos'] as List?)
          ?.map((e) => TopProduto.fromJson(Map<String, dynamic>.from(e)))
          .toList() ?? [],
      alertaEstoque: _i(json['alertaEstoque']),
    );
  }
}

class KpiBlock {
  final int qtd;
  final double receita;
  KpiBlock({required this.qtd, required this.receita});
}

class TopProduto {
  final String descricao;
  final double qtdVendida;
  final double total;

  TopProduto({required this.descricao, required this.qtdVendida, required this.total});

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory TopProduto.fromJson(Map<String, dynamic> json) {
    return TopProduto(
      descricao: json['descricao']?.toString() ?? '',
      qtdVendida: _d(json['qtd_vendida']),
      total: _d(json['total']),
    );
  }
}

class VendaDiaria {
  final String data;
  final int qtd;
  final double receita;

  VendaDiaria({required this.data, required this.qtd, required this.receita});

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory VendaDiaria.fromJson(Map<String, dynamic> json) {
    return VendaDiaria(
      data: json['data']?.toString() ?? '',
      qtd: _i(json['qtd']),
      receita: _d(json['receita']),
    );
  }
}

class ReportItem {
  final String label;
  final double total;
  final int qtd;

  ReportItem({required this.label, required this.total, required this.qtd});

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class ReportService {
  static Future<DashboardData> dashboard() async {
    try {
      final res = await ApiClient.dio.get('/reports/dashboard');
      return DashboardData.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<VendaDiaria>> vendasPorPeriodo(String inicio, String fim) async {
    try {
      final res = await ApiClient.dio.get('/reports/vendas-periodo', queryParameters: {'inicio': inicio, 'fim': fim});
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => VendaDiaria.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<ReportItem>> topProdutos({String? inicio, String? fim, int limit = 10}) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (inicio != null) params['inicio'] = inicio;
      if (fim != null) params['fim'] = fim;

      final res = await ApiClient.dio.get('/reports/top-produtos', queryParameters: params);
      if (res.data is List) {
        return (res.data as List).whereType<Map>().map((m) {
          final j = Map<String, dynamic>.from(m);
          return ReportItem(
            label: j['descricao']?.toString() ?? '',
            total: ReportItem._d(j['total']),
            qtd: ReportItem._i(j['qtd_vendida']),
          );
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<ReportItem>> porCategoria({String? inicio, String? fim}) async {
    try {
      final params = <String, dynamic>{};
      if (inicio != null) params['inicio'] = inicio;
      if (fim != null) params['fim'] = fim;

      final res = await ApiClient.dio.get('/reports/por-categoria', queryParameters: params);
      if (res.data is List) {
        return (res.data as List).whereType<Map>().map((m) {
          final j = Map<String, dynamic>.from(m);
          return ReportItem(
            label: j['categoria']?.toString() ?? '',
            total: ReportItem._d(j['total']),
            qtd: ReportItem._i(j['qtd_vendas']),
          );
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<ReportItem>> porPagamento({String? inicio, String? fim}) async {
    try {
      final params = <String, dynamic>{};
      if (inicio != null) params['inicio'] = inicio;
      if (fim != null) params['fim'] = fim;

      final res = await ApiClient.dio.get('/reports/por-pagamento', queryParameters: params);
      if (res.data is List) {
        return (res.data as List).whereType<Map>().map((m) {
          final j = Map<String, dynamic>.from(m);
          return ReportItem(
            label: j['forma']?.toString() ?? '',
            total: ReportItem._d(j['total']),
            qtd: ReportItem._i(j['qtd']),
          );
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<ReportItem>> porOperador({String? inicio, String? fim}) async {
    try {
      final params = <String, dynamic>{};
      if (inicio != null) params['inicio'] = inicio;
      if (fim != null) params['fim'] = fim;

      final res = await ApiClient.dio.get('/reports/por-operador', queryParameters: params);
      if (res.data is List) {
        return (res.data as List).whereType<Map>().map((m) {
          final j = Map<String, dynamic>.from(m);
          return ReportItem(
            label: j['operador']?.toString() ?? '',
            total: ReportItem._d(j['total']),
            qtd: ReportItem._i(j['qtd_vendas']),
          );
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
