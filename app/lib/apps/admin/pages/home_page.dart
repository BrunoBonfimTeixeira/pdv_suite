import 'dart:async';
import 'package:flutter/material.dart';

import 'package:pdv_lanchonete/core/models/item_carrinho.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/models/venda.dart';

import 'package:pdv_lanchonete/core/services/produto_service.dart';
import 'package:pdv_lanchonete/core/services/usuario_service.dart';
import 'package:pdv_lanchonete/core/services/venda_service.dart';

/// Modelo simples só para a lista de produtos na tela
class ProdutoResumo {
  final int id;
  final String descricao;
  final double preco;

  ProdutoResumo({
    required this.id,
    required this.descricao,
    required this.preco,
  });
}

/// Item que vai para o carrinho (apenas na memória do app)
class _ItemCarrinho {
  final int produtoId;
  final String descricao;
  final double preco;
  int quantidade;

  _ItemCarrinho({
    required this.produtoId,
    required this.descricao,
    required this.preco,
    this.quantidade = 1,
  });

  double get total => preco * quantidade;
}

class PdvShell extends StatefulWidget {
  const PdvShell({super.key});

  @override
  State<PdvShell> createState() => _PdvShellState();
}

class _PdvShellState extends State<PdvShell> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  final TextEditingController _codigoCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();

  Usuario? _usuario; // ✅ do jeito certo
  String? _erroLogin;
  bool _logando = false;

  final List<_ItemCarrinho> _carrinho = [];

  double get _totalCarrinho =>
      _carrinho.fold(0.0, (soma, item) => soma + item.total);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _codigoCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  // ---------------- LOGIN ----------------

  Future<void> _fazerLogin() async {
    if (_logando) return;

    setState(() {
      _erroLogin = null;
      _logando = true;
    });

    final codigo = _codigoCtrl.text.trim();
    final senha = _senhaCtrl.text.trim();

    if (codigo.isEmpty || senha.isEmpty) {
      setState(() {
        _erroLogin = 'Informe código e senha.';
        _logando = false;
      });
      return;
    }

    try {
      final usuario = await UsuarioService.autenticar(
        login: codigo,
        senha: senha,
      );

      if (!mounted) return;

      if (usuario == null) {
        setState(() {
          _erroLogin = 'Login ou senha inválidos.';
          _logando = false;
        });
        return;
      }

      setState(() {
        _usuario = usuario;
        _codigoCtrl.clear();
        _senhaCtrl.clear();
        _logando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroLogin = e.toString();
        _logando = false;
      });
    }
  }

  void _logout() {
    setState(() {
      _usuario = null;
      _carrinho.clear();
      _erroLogin = null;
    });
  }

  // ---------------- CARRINHO ----------------

  void _adicionarProdutoAoCarrinho(ProdutoResumo p) {
    setState(() {
      final idx = _carrinho.indexWhere((item) => item.produtoId == p.id);
      if (idx == -1) {
        _carrinho.add(
          _ItemCarrinho(
            produtoId: p.id,
            descricao: p.descricao,
            preco: p.preco,
          ),
        );
      } else {
        _carrinho[idx].quantidade++;
      }
    });
  }

  void _incrementarItem(_ItemCarrinho item) {
    setState(() => item.quantidade++);
  }

  void _decrementarItem(_ItemCarrinho item) {
    setState(() {
      item.quantidade--;
      if (item.quantidade <= 0) _carrinho.remove(item);
    });
  }

  void _limparCarrinho() {
    setState(() => _carrinho.clear());
  }

  Future<void> _finalizarVenda() async {
    if (_usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login antes de finalizar a venda.')),
      );
      return;
    }

    if (_carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há itens no carrinho.')),
      );
      return;
    }

    // TODO (futuro): pegar do caixa aberto
    const int caixaId = 1;

    final int usuarioId = _usuario!.id;

    try {
      final venda = Venda(
        itens: _carrinho.map((i) {
          return ItemCarrinho(
            produtoId: i.produtoId,
            descricao: i.descricao,
            quantidade: i.quantidade,
            preco: i.preco,
          );
        }).toList(),
      );

      final vendaId = await VendaService.salvarVenda(
        caixaId: caixaId,
        usuarioId: usuarioId,
        venda: venda,
      );

      setState(() => _carrinho.clear());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Venda #$vendaId salva com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erro ao salvar venda: $e')),
      );
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final operadorNome = _usuario?.nome;

    final timeStr =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${_now.day.toString().padLeft(2, '0')}/${_now.month.toString().padLeft(2, '0')}/${_now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFF10141A),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              timeStr: timeStr,
              dateStr: dateStr,
              operador: operadorNome,
              // ✅ já fica pronto pra botar Admin:
              perfil: _usuario?.perfil,
              onAbrirAdmin: () {
                // TODO: aqui você navega para a tela Admin quando criar rota/import.
                // Ex:
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsuariosPage()));
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: _LoginPanel(
                        codigoCtrl: _codigoCtrl,
                        senhaCtrl: _senhaCtrl,
                        operador: operadorNome,
                        erro: _erroLogin,
                        carregando: _logando,
                        onLogin: _fazerLogin,
                        onLogout: _logout,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 9,
                      child: _MainPanel(
                        operador: operadorNome,
                        itensCarrinho: _carrinho,
                        totalCarrinho: _totalCarrinho,
                        onAdicionarProduto: _adicionarProdutoAoCarrinho,
                        onIncrementarItem: _incrementarItem,
                        onDecrementarItem: _decrementarItem,
                        onLimparCarrinho: _limparCarrinho,
                        onFinalizarVenda: _finalizarVenda,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _FooterBar(operador: operadorNome),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class _HeaderBar extends StatelessWidget {
  final String timeStr;
  final String dateStr;
  final String? operador;

  // pra ficar pronto pro futuro:
  final String? perfil;
  final VoidCallback onAbrirAdmin;

  const _HeaderBar({
    required this.timeStr,
    required this.dateStr,
    required this.operador,
    required this.perfil,
    required this.onAbrirAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = (perfil == 'ADMIN');

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0072B2), Color(0xFF00B28C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Text(
                  'L',
                  style: TextStyle(
                    color: Color(0xFF0072B2),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Lúbru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'CAIXA 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PDV Desktop',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Operador',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    operador ?? 'Sem Operador',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // ✅ Deixa pronto: só aparece se for ADMIN
              if (isAdmin)
                IconButton(
                  tooltip: 'Admin',
                  onPressed: onAbrirAdmin,
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                ),

              const Icon(Icons.settings, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// LOGIN PANEL
// --------------------------------------------------

class _LoginPanel extends StatelessWidget {
  final TextEditingController codigoCtrl;
  final TextEditingController senhaCtrl;
  final String? operador;
  final String? erro;
  final bool carregando;
  final Future<void> Function() onLogin;
  final VoidCallback onLogout;

  const _LoginPanel({
    required this.codigoCtrl,
    required this.senhaCtrl,
    required this.operador,
    required this.erro,
    required this.carregando,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181E26),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOGIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: codigoCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Digite seu Código',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.badge, color: Colors.white54),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00B28C), width: 2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: senhaCtrl,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Digite sua Senha',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00B28C), width: 2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
          ),
          if (erro != null) ...[
            const SizedBox(height: 16),
            Text(
              erro!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: carregando ? null : () => onLogin(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF00B28C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: carregando
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (operador != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                label: const Text('Trocar Operador'),
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// MAIN PANEL (o restante do seu código permanece igual)
// --------------------------------------------------

class _MainPanel extends StatelessWidget {
  final String? operador;
  final List<_ItemCarrinho> itensCarrinho;
  final double totalCarrinho;
  final void Function(ProdutoResumo produto) onAdicionarProduto;
  final void Function(_ItemCarrinho item) onIncrementarItem;
  final void Function(_ItemCarrinho item) onDecrementarItem;
  final VoidCallback onLimparCarrinho;
  final Future<void> Function() onFinalizarVenda;

  const _MainPanel({
    required this.operador,
    required this.itensCarrinho,
    required this.totalCarrinho,
    required this.onAdicionarProduto,
    required this.onIncrementarItem,
    required this.onDecrementarItem,
    required this.onLimparCarrinho,
    required this.onFinalizarVenda,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181E26),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'VENDAS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white60, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      operador ?? 'Sem Operador',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: operador == null
                ? const _SemOperadorView()
                : Row(
              children: [
                Expanded(
                  flex: 7,
                  child: _ListaProdutos(
                    onSelecionarProduto: onAdicionarProduto,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: _CarrinhoPanel(
                    itens: itensCarrinho,
                    total: totalCarrinho,
                    onIncrementar: onIncrementarItem,
                    onDecrementar: onDecrementarItem,
                    onLimpar: onLimparCarrinho,
                    onFinalizar: onFinalizarVenda,
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

class _SemOperadorView extends StatelessWidget {
  const _SemOperadorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Faça login para iniciar as vendas',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Lista de produtos (API)
class _ListaProdutos extends StatefulWidget {
  final void Function(ProdutoResumo produto) onSelecionarProduto;

  const _ListaProdutos({required this.onSelecionarProduto});

  @override
  State<_ListaProdutos> createState() => _ListaProdutosState();
}

class _ListaProdutosState extends State<_ListaProdutos> {
  final TextEditingController _buscaCtrl = TextEditingController();

  bool _carregando = false;
  String? _erro;
  List<ProdutoResumo> _produtos = [];
  List<ProdutoResumo> _filtrados = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _buscaCtrl.addListener(_aplicarFiltro);
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await ProdutoService.listar(filtro: _buscaCtrl.text.trim());

      setState(() {
        _produtos = lista
            .map((p) => ProdutoResumo(
          id: p.id,
          descricao: p.descricao,
          preco: (p.preco as num).toDouble(),
        ))
            .toList();
        _filtrados = _produtos;
      });
    } catch (e) {
      setState(() => _erro = 'Erro ao carregar produtos: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _aplicarFiltro() {
    final q = _buscaCtrl.text.toLowerCase();

    setState(() {
      if (q.isEmpty) {
        _filtrados = _produtos;
      } else {
        _filtrados = _produtos.where((p) {
          return p.descricao.toLowerCase().contains(q) || p.id.toString().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _buscaCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar produto (código, descrição, código de barras)...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white60),
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white60),
              onPressed: _carregarProdutos,
            ),
            filled: true,
            fillColor: const Color(0xFF10141A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: const Color(0xFF10141A),
              child: _carregando
                  ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B28C)),
                ),
              )
                  : _erro != null
                  ? Center(
                child: Text(
                  _erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              )
                  : _filtrados.isEmpty
                  ? const Center(
                child: Text(
                  'Nenhum produto encontrado.',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              )
                  : ListView.separated(
                itemCount: _filtrados.length,
                separatorBuilder: (_, __) =>
                const Divider(color: Colors.white12, height: 1),
                itemBuilder: (context, index) {
                  final p = _filtrados[index];
                  return ListTile(
                    onTap: () => widget.onSelecionarProduto(p),
                    dense: true,
                    title: Text(
                      p.descricao,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      'ID: ${p.id}',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    trailing: Text(
                      'R\$ ${p.preco.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF00B28C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Painel do carrinho (itens + total + ações)
class _CarrinhoPanel extends StatelessWidget {
  final List<_ItemCarrinho> itens;
  final double total;
  final void Function(_ItemCarrinho item) onIncrementar;
  final void Function(_ItemCarrinho item) onDecrementar;
  final VoidCallback onLimpar;
  final Future<void> Function() onFinalizar;

  const _CarrinhoPanel({
    required this.itens,
    required this.total,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.onLimpar,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CARRINHO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF10141A),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: itens.isEmpty
                ? const Center(
              child: Text(
                'Nenhum item no carrinho.',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            )
                : ListView.separated(
              itemCount: itens.length,
              separatorBuilder: (_, __) =>
              const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final item = itens[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    item.descricao,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Qtd: ${item.quantidade}  •  R\$ ${item.preco.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  trailing: SizedBox(
                    width: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 20, color: Colors.white60),
                          onPressed: () => onDecrementar(item),
                        ),
                        Text(
                          'R\$ ${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF00B28C),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              size: 20, color: Colors.white60),
                          onPressed: () => onIncrementar(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'TOTAL',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
            ),
            Text(
              'R\$ ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF00B28C),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: itens.isEmpty ? null : onLimpar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('Limpar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: itens.isEmpty ? null : () => onFinalizar(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B28C)),
                child: const Text(
                  'Finalizar venda',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --------------------------------------------------
// FOOTER
// --------------------------------------------------

class _FooterBar extends StatelessWidget {
  final String? operador;

  const _FooterBar({required this.operador});

  @override
  Widget build(BuildContext context) {
    final bool logado = operador != null;

    return Container(
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0072B2), Color(0xFF00B28C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Center(
        child: Text(
          logado ? operador!.toUpperCase() : 'SEM OPERADOR',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
