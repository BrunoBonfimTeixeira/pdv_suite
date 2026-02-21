import 'produto.dart';

class ItemCarrinho {
  final int produtoId;
  final String descricao;
  final double preco;
  final String unidade;
  int quantidade;

  // Desconto por item
  double descontoPercentual;
  double descontoValor;

  ItemCarrinho({
    required this.produtoId,
    required this.descricao,
    required this.preco,
    this.unidade = 'UN',
    this.quantidade = 1,
    this.descontoPercentual = 0,
    this.descontoValor = 0,
  });

  factory ItemCarrinho.fromProduto(Produto p, {int quantidade = 1}) {
    return ItemCarrinho(
      produtoId: p.id,
      descricao: p.descricao,
      preco: p.preco,
      unidade: p.unidadeMedida,
      quantidade: quantidade,
    );
  }

  double get subtotalBruto => preco * quantidade;

  double get descontoCalculado {
    if (descontoPercentual > 0) {
      return subtotalBruto * descontoPercentual / 100;
    }
    return descontoValor;
  }

  double get subtotal => subtotalBruto - descontoCalculado;

  void setDescontoPercentual(double pct) {
    descontoPercentual = pct;
    descontoValor = 0;
  }

  void setDescontoValor(double valor) {
    descontoValor = valor;
    descontoPercentual = 0;
  }

  Map<String, dynamic> toJson() => {
    'produtoId': produtoId,
    'quantidade': quantidade,
    'preco': preco,
    'total': subtotalBruto,
    'descontoPercentual': descontoPercentual,
    'descontoValor': descontoCalculado,
  };
}
