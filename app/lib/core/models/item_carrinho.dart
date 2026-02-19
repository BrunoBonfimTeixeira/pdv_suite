import 'produto.dart';

class ItemCarrinho {
  /// ID do produto na tabela `produtos`
  final int produtoId;

  /// Nome para exibir no PDV
  final String descricao;

  /// Preço unitário
  final double preco;

  /// Quantidade no carrinho
  int quantidade;

  ItemCarrinho({
    required this.produtoId,
    required this.descricao,
    required this.preco,
    this.quantidade = 1,
  });

  /// Construtor que cria automaticamente a partir do Produto
  factory ItemCarrinho.fromProduto(Produto p, {int quantidade = 1}) {
    return ItemCarrinho(
      produtoId: p.id,
      descricao: p.descricao,
      preco: p.preco,
      quantidade: quantidade,
    );
  }

  double get subtotal => preco * quantidade;

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId,
    'descricao': descricao,
    'quantidade': quantidade,
    'preco_unitario': preco,
    'total': subtotal,
  };
}
