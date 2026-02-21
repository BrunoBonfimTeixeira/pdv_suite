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
import 'package:pdv_lanchonete/apps/pdv/dialogs/sangria_dialog.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/suprimento_dialog.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/desconto_venda_dialog.dart';
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
  final TextEditingController _barcodeCtrl = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();
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
    _barcodeCtrl.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  void _onLoggedIn(Usuario usuario) {
    _ctrl.setUsuario(usuario);
    _ctrl.verificarCaixaAberto();
    _ctrl.carregarFormasPagamento();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  // ─── BARCODE INPUT ───

  void _onBarcodeSubmitted(String value) {
    final code = value.trim();
    if (code.isEmpty) return;

    _barcodeCtrl.clear();

    if (!_ctrl.caixaEstaAberto) {
      _showSnack('Abra o caixa primeiro (F1).', isError: true);
      return;
    }

    _ctrl.adicionarPorCodigoBarras(code).then((found) {
      if (!found) {
        _showSnack('Produto nao encontrado: $code', isError: true);
      }
    });
  }

  // ─── KEYBOARD SHORTCUTS ───

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_dialogOpen) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Teclas de funcao sempre funcionam
    if (key == LogicalKeyboardKey.f1) { _abrirCaixa(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.f2) { _fecharCaixa(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.f3) { _buscarProdutos(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.f4) { _buscarPessoas(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.f5) { _sangria(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.f6) { _suprimento(); return KeyEventResult.handled; }

    // Teclas de letra - verificar se nao esta em campo de texto
    final primaryFocus = FocusManager.instance.primaryFocus;
    final isTextInput = primaryFocus?.context?.widget is EditableText;
    if (isTextInput) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.keyF) { _finalizarVenda(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.keyC) { _cancelarVenda(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.keyR) { _reimprimir(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.keyI) { _ctrl.toggleImpressoraAutomatica(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.keyB) { _balanca(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.keyP) { _finalizarVenda(); return KeyEventResult.handled; }
    if (key == LogicalKeyboardKey.keyD) { _descontoVenda(); return KeyEventResult.handled; }

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

  Future<void> _sangria() async {
    if (!_ctrl.caixaEstaAberto) {
      _showSnack('Abra o caixa primeiro (F1).', isError: true);
      return;
    }

    _dialogOpen = true;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const SangriaDialog(),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (result == null) return;

    try {
      await _ctrl.registrarSangria(
        valor: result['valor'] as double,
        motivo: result['motivo'] as String?,
      );
      _showSnack(_ctrl.mensagem);
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<void> _suprimento() async {
    if (!_ctrl.caixaEstaAberto) {
      _showSnack('Abra o caixa primeiro (F1).', isError: true);
      return;
    }

    _dialogOpen = true;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const SuprimentoDialog(),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (result == null) return;

    try {
      await _ctrl.registrarSuprimento(
        valor: result['valor'] as double,
        motivo: result['motivo'] as String?,
      );
      _showSnack(_ctrl.mensagem);
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<void> _descontoVenda() async {
    if (!_ctrl.temItens) {
      _showSnack('Adicione itens primeiro.', isError: true);
      return;
    }

    _dialogOpen = true;
    final result = await showDialog<double>(
      context: context,
      builder: (_) => DescontoVendaDialog(
        totalBruto: _ctrl.totalBruto,
        descontoAtual: _ctrl.descontoVenda,
      ),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (result == null) return;
    _ctrl.setDescontoVenda(result);
    if (result > 0) {
      _showSnack('Desconto de R\$ ${result.toStringAsFixed(2)} aplicado na venda.');
    } else {
      _showSnack('Desconto removido.');
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
        total: _ctrl.totalLiquido,
        formasPagamento: _ctrl.formasPagamento,
      ),
    );
    _dialogOpen = false;
    _focusNode.requestFocus();

    if (pagamentos == null) return;

    try {
      final vendaId = await _ctrl.finalizarVenda(pagamentos: pagamentos);

      // Mostrar troco se houver
      if (_ctrl.ultimoTroco != null && _ctrl.ultimoTroco! > 0.01) {
        _showTrocoDialog(_ctrl.ultimoTroco!, vendaId);
      } else {
        _showSnack(_ctrl.mensagem);
      }
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  void _showTrocoDialog(double troco, int vendaId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: PdvTheme.accent, size: 28),
            SizedBox(width: 10),
            Text('Venda Finalizada!', style: TextStyle(color: PdvTheme.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Venda #$vendaId', style: const TextStyle(color: PdvTheme.textSecondary)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PdvTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PdvTheme.warning.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text('TROCO', style: TextStyle(color: PdvTheme.warning, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${troco.toStringAsFixed(2)}',
                    style: const TextStyle(color: PdvTheme.warning, fontSize: 42, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: PdvTheme.accent, foregroundColor: PdvTheme.bg),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
              // Barcode input bar
              if (_ctrl.caixaEstaAberto)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: const BoxDecoration(
                    color: PdvTheme.surface,
                    border: Border(bottom: BorderSide(color: PdvTheme.border)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner, color: PdvTheme.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _barcodeCtrl,
                          focusNode: _barcodeFocus,
                          style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Codigo de barras / nome do produto...',
                            hintStyle: TextStyle(color: PdvTheme.textSecondary),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: _onBarcodeSubmitted,
                        ),
                      ),
                    ],
                  ),
                ),
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
