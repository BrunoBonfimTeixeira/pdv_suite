import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_controller.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';
import 'package:pdv_lanchonete/apps/pdv/widgets/pdv_top_bar.dart';
import 'package:pdv_lanchonete/apps/pdv/widgets/pdv_itens_panel.dart';
import 'package:pdv_lanchonete/apps/pdv/widgets/pdv_resumo_panel.dart';
import 'package:pdv_lanchonete/apps/pdv/widgets/pdv_shortcut_bar.dart';
import 'package:pdv_lanchonete/apps/pdv/widgets/pdv_login_panel.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/abrir_caixa_dialog.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/fechar_caixa_dialog.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/busca_produtos_dialog.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/busca_pessoas_dialog.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/finalizar_venda_dialog.dart';
import 'package:pdv_lanchonete/core/models/pessoa.dart';
import 'package:pdv_lanchonete/core/models/produto.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';
import 'package:pdv_lanchonete/core/services/auth_service.dart';

class PdvScreen extends StatefulWidget {
  const PdvScreen({super.key});

  @override
  State<PdvScreen> createState() => _PdvScreenState();
}

class _PdvScreenState extends State<PdvScreen> {
  final PdvController _ctrl = PdvController();
  final FocusNode _focusNode = FocusNode();
  bool _booting = true;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onCtrlChanged);
    _boot();
  }

  Future<void> _boot() async {
    ApiClient.init();
    final user = await AuthService.tryRestoreSession();
    if (user != null) {
      _ctrl.setUsuario(user);
      await _ctrl.verificarCaixaAberto();
      await _ctrl.carregarFormasPagamento();
    }
    if (mounted) setState(() => _booting = false);
  }

  void _onCtrlChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onCtrlChanged);
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onLoggedIn(Usuario usuario) {
    _ctrl.setUsuario(usuario);
    _ctrl.verificarCaixaAberto();
    _ctrl.carregarFormasPagamento();
    // Garante que o focus node pega foco apos o rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  // ─── KEYBOARD SHORTCUTS ───

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_dialogOpen) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Teclas de funcao sempre funcionam
    if (key == LogicalKeyboardKey.f1) {
      _abrirCaixa();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.f2) {
      _fecharCaixa();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.f3) {
      _buscarProdutos();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.f4) {
      _buscarPessoas();
      return KeyEventResult.handled;
    }

    // Teclas de letra - verificar se nao esta em campo de texto
    final primaryFocus = FocusManager.instance.primaryFocus;
    final isTextInput = primaryFocus?.context?.widget is EditableText;
    if (isTextInput) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.keyF) {
      _finalizarVenda();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyC) {
      _cancelarVenda();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyR) {
      _reimprimir();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyI) {
      _ctrl.toggleImpressoraAutomatica();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyB) {
      _balanca();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyP) {
      _finalizarVenda();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ─── ACTIONS ───

  Future<void> _abrirCaixa() async {
    if (_ctrl.caixaEstaAberto) {
      _showSnack('Caixa ja esta aberto (#${_ctrl.caixaAberto!.id})');
      return;
    }

    _dialogOpen = true;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AbrirCaixaDialog(),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (result == null) return;

    try {
      await _ctrl.abrirCaixa(
        valorAbertura: result['valorAbertura'] ?? 0,
        observacoes: result['observacoes'],
      );
      _showSnack(_ctrl.mensagem);
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<void> _fecharCaixa() async {
    if (!_ctrl.caixaEstaAberto) {
      _showSnack('Nenhum caixa aberto.', isError: true);
      return;
    }

    _dialogOpen = true;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => FecharCaixaDialog(caixaId: _ctrl.caixaAberto!.id),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (result == null) return;

    try {
      final res = await _ctrl.fecharCaixa(
        valorFechamento: result['valorFechamento'] as double?,
        observacoes: result['observacoes'] as String?,
      );
      _showSnack(
        'Caixa fechado! Sistema: R\$ ${(res['valorSistema'] as num?)?.toStringAsFixed(2) ?? '?'} '
        '| Diferenca: R\$ ${(res['diferenca'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
      );
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<void> _buscarProdutos() async {
    _dialogOpen = true;
    final produto = await showDialog<Produto>(
      context: context,
      builder: (_) => const BuscaProdutosDialog(),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (produto != null) {
      _ctrl.adicionarProduto(produto);
    }
  }

  Future<void> _buscarPessoas() async {
    _dialogOpen = true;
    final pessoa = await showDialog<Pessoa>(
      context: context,
      builder: (_) => const BuscaPessoasDialog(),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (pessoa != null) {
      _ctrl.setCliente(pessoa);
    }
  }

  Future<void> _finalizarVenda() async {
    if (!_ctrl.caixaEstaAberto) {
      _showSnack('Abra o caixa primeiro (F1).', isError: true);
      return;
    }
    if (!_ctrl.temItens) {
      _showSnack('Adicione itens ao carrinho (F3).', isError: true);
      return;
    }

    _dialogOpen = true;
    final pagamentos = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (_) => FinalizarVendaDialog(
        total: _ctrl.totalBruto,
        formasPagamento: _ctrl.formasPagamento,
      ),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (pagamentos == null) return;

    try {
      await _ctrl.finalizarVenda(pagamentos: pagamentos);
      _showSnack(_ctrl.mensagem);
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  void _cancelarVenda() {
    if (!_ctrl.temItens) return;
    _ctrl.cancelarVendaAtual();
    _showSnack('Venda cancelada.');
  }

  void _reimprimir() {
    if (_ctrl.ultimaVendaId == null) {
      _showSnack('Nenhuma venda para reimprimir.', isError: true);
      return;
    }
    _showSnack('Reimprimir venda #${_ctrl.ultimaVendaId} (placeholder)');
  }

  void _balanca() {
    _showSnack('Balanca (placeholder)');
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? PdvTheme.danger : PdvTheme.accent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return const Scaffold(
        backgroundColor: PdvTheme.bg,
        body: Center(child: CircularProgressIndicator(color: PdvTheme.accent)),
      );
    }

    // Not logged in
    if (_ctrl.usuario == null) {
      return Scaffold(
        backgroundColor: PdvTheme.bg,
        body: PdvLoginPanel(onLoggedIn: _onLoggedIn),
      );
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          backgroundColor: PdvTheme.bg,
          body: Column(
            children: [
              PdvTopBar(controller: _ctrl),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PdvItensPanel(controller: _ctrl),
                    ),
                    SizedBox(
                      width: 320,
                      child: PdvResumoPanel(
                        controller: _ctrl,
                        onFinalizar: _finalizarVenda,
                        onCancelar: _cancelarVenda,
                      ),
                    ),
                  ],
                ),
              ),
              const PdvShortcutBar(),
            ],
          ),
        ),
      ),
    );
  }
}
