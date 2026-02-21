import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/pessoa.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class PessoaService {
  static Future<List<Pessoa>> listar({String? q, String? tipo}) async {
    try {
      final params = <String, dynamic>{};
      if (q != null && q.isNotEmpty) params['q'] = q;
      if (tipo != null && tipo.isNotEmpty) params['tipo'] = tipo;

      final res = await ApiClient.dio.get('/pessoas', queryParameters: params);
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => Pessoa.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<Pessoa> buscarPorId(int id) async {
    try {
      final res = await ApiClient.dio.get('/pessoas/$id');
      return Pessoa.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<int> criar({
    required String nome,
    String? cpfCnpj,
    String? telefone,
    String? email,
    String? endereco,
    String tipo = 'CLIENTE',
  }) async {
    try {
      final res = await ApiClient.dio.post('/pessoas', data: {
        'nome': nome,
        if (cpfCnpj != null) 'cpfCnpj': cpfCnpj,
        if (telefone != null) 'telefone': telefone,
        if (email != null) 'email': email,
        if (endereco != null) 'endereco': endereco,
        'tipo': tipo,
      });
      return (res.data['id'] as num).toInt();
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> atualizar({
    required int id,
    String? nome,
    String? cpfCnpj,
    String? telefone,
    String? email,
    String? endereco,
    String? tipo,
    bool? ativo,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (nome != null) payload['nome'] = nome;
      if (cpfCnpj != null) payload['cpfCnpj'] = cpfCnpj;
      if (telefone != null) payload['telefone'] = telefone;
      if (email != null) payload['email'] = email;
      if (endereco != null) payload['endereco'] = endereco;
      if (tipo != null) payload['tipo'] = tipo;
      if (ativo != null) payload['ativo'] = ativo;

      await ApiClient.dio.patch('/pessoas/$id', data: payload);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> remover(int id) async {
    try {
      await ApiClient.dio.delete('/pessoas/$id');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
