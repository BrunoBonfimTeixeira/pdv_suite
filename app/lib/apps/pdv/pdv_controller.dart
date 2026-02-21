import 'package:flutter/foundation.dart';
import 'package:pdv_lanchonete/core/models/caixa.dart';
import 'package:pdv_lanchonete/core/models/forma_pagamento.dart';
import 'package:pdv_lanchonete/core/models/item_carrinho.dart';
import 'package:pdv_lanchonete/core/models/pessoa.dart';
import 'package:pdv_lanchonete/core/models/produto.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/models/venda.dart';
import 'package:pdv_lanchonete/core/services/caixa_service.dart';
import 'package:pdv_lanchonete/core/services/forma_pagamento_service.dart';
import 'package:pdv_lanchonete/core/services/venda_service.dart';

class PdvController extends ChangeNotifier {
  // Estado do operador
  Usuario? usuario;
  Caixa? caixaAberto;

  // Itens do carrinho
  final List<ItemCarrinho> itens = [];

  // Formas de pagamento disponíveis
  List<FormaPagamento> formasPagamento = [];

  // Cliente selecionado
  Pessoa? clienteSelecionado;

  // Última venda finalizada (para reimprimir)
  int? ultimaVendaId;

  // Impressora automática
  bool impressoraAutomatica = false;

  // Status
  String? erro;
  bool processando = false;
  String mensagem = '';

  bool get caixaEstaAberto => caixaAberto != null;
  bool get temItens => itens.isNotEmpty;

  double get totalBruto => itens.fold(0, (s, i) => s + i.subtotal);
  int get totalItens => itens.fold(0, (s, i) => s + i.quantidade);

  void setUsuario(Usuario u) {
    usuario = u;
    notifyListeners();
  }

  // ─── CAIXA ───

  Future<void> verificarCaixaAberto() async {
    try {
      caixaAberto = await CaixaService.buscarAberto();
      notifyListeners();
    } catch (e) {
      erro = e.toString();
      notifyListeners();
    }
  }

  Future<int> abrirCaixa({double valorAbertura = 0, String? observacoes}) async {
    processando = true;
    notifyListeners();
    try {
      final id = await CaixaService.abrir(
        valorAbertura: valorAbertura,
        observacoes: observacoes,
      );
      await verificarCaixaAberto();
      mensagem = 'Caixa #$id aberto com sucesso!';
      processando = false;
      notifyListeners();
      return id;
    } catch (e) {
      processando = false;
      erro = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fecharCaixa({double? valorFechamento, String? observacoes}) async {
    if (caixaAberto == null) throw Exception('Nenhum caixa aberto.');
    processando = true;
    notifyListeners();
    try {
      final result = await CaixaService.fechar(
        caixaId: caixaAberto!.id,
        valorFechamento: valorFechamento,
        observacoes: observacoes,
      );
      caixaAberto = null;
      limparVenda();
      mensagem = 'Caixa fechado com sucesso!';
      processando = false;
      notifyListeners();
      return result;
    } catch (e) {
      processando = false;
      erro = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ─── FORMAS DE PAGAMENTO ───

  Future<void> carregarFormasPagamento() async {
    try {
      formasPagamento = await FormaPagamentoService.listar();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar formas: $e');
    }
  }

  // ─── ITENS ───

  void adicionarProduto(Produto produto, {int quantidade = 1}) {
    final idx = itens.indexWhere((i) => i.produtoId == produto.id);
    if (idx >= 0) {
      itens[idx].quantidade += quantidade;
    } else {
      itens.add(ItemCarrinho.fromProduto(produto, quantidade: quantidade));
    }
    erro = null;
    notifyListeners();
  }

  void removerItem(int index) {
    if (index >= 0 && index < itens.length) {
      itens.removeAt(index);
      notifyListeners();
    }
  }

  void alterarQuantidade(int index, int novaQtd) {
    if (index >= 0 && index < itens.length && novaQtd > 0) {
      itens[index].quantidade = novaQtd;
      notifyListeners();
    }
  }

  void setCliente(Pessoa? pessoa) {
    clienteSelecionado = pessoa;
    notifyListeners();
  }

  // ─── VENDA ───

  Future<int> finalizarVenda({List<Map<String, dynamic>>? pagamentos}) async {
    if (!caixaEstaAberto) throw Exception('Caixa não está aberto.');
    if (!temItens) throw Exception('Adicione itens ao carrinho.');

    processando = true;
    notifyListeners();

    try {
      final venda = Venda(itens: List.from(itens));

      final vendaId = await VendaService.salvarVenda(
        caixaId: caixaAberto!.id,
        usuarioId: usuario!.id,
        venda: venda,
        pessoaId: clienteSelecionado?.id,
        pagamentos: pagamentos,
      );

      ultimaVendaId = vendaId;
      limparVenda();
      mensagem = 'Venda #$vendaId finalizada!';
      processando = false;
      notifyListeners();
      return vendaId;
    } catch (e) {
      processando = false;
      erro = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void cancelarVendaAtual() {
    limparVenda();
    mensagem = 'Venda cancelada.';
    notifyListeners();
  }

  void limparVenda() {
    itens.clear();
    clienteSelecionado = null;
    erro = null;
    notifyListeners();
  }

  void toggleImpressoraAutomatica() {
    impressoraAutomatica = !impressoraAutomatica;
    notifyListeners();
  }

  void limparMensagem() {
    mensagem = '';
    erro = null;
    notifyListeners();
  }
}
