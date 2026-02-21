import 'item_carrinho.dart';

class Venda {
  final List<ItemCarrinho> itens;
  final String meioPagamento;

  Venda({
    required this.itens,
    this.meioPagamento = 'Dinheiro',
  });

  double get total =>
      itens.fold(0, (sum, item) => sum + item.subtotal);

  Map<String, dynamic> toJson() => {
    'itens': itens.map((e) => e.toJson()).toList(),
    'pagamentos': [
      {'meio': meioPagamento, 'valor': total}
    ],
    'total': total,
  };
}
