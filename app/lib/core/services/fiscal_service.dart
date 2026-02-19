import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venda.dart';

class FiscalService {
  final String baseUrl;

  FiscalService({this.baseUrl = 'http://localhost:7071'});

  Future<Map<String, dynamic>> emitirNFCe(Venda venda) async {
    final uri = Uri.parse('$baseUrl/nfe/authorize');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(venda.toJson()),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Erro HTTP ${resp.statusCode}: ${resp.reasonPhrase}');
    }
  }
}
