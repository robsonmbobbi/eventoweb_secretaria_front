import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_forma_pagamento.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_pesquisa_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_preco_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/pedidos/dto_pedido_inclusao.dart';
import 'package:eventoweb_secretaria_front/data/models/pedidos/enum_tipo_pedido.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/formas_pagamento_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/inscricoes_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/precos_inscricao_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/pedidos/pedidos_ws.dart';
import 'package:eventoweb_secretaria_front/utils/command.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../event_shell/view_model/event_shell_viewmodel.dart';

class PedidoCadastroViewModel extends ChangeNotifier {
  final InscricoesWS inscricoesWS;
  final PrecosInscricaoWS precosWS;
  final FormasPagamentoWS formasPagamentoWS;
  final PedidosWS pedidosWS;
  final EventShellViewModel eventViewModel;

  List<DTOInscricao> inscricoesNoPedido = [];
  List<DTOFormaPagamento> formasPagamento = [];
  DTOFormaPagamento? formaSelecionada;
  
  // Controle do Wizard
  DTOInscricaoPesquisaPessoa? pesquisaAtual;
  DTOPrecoInscricao? precoDefinido;
  
  // Controllers para formulário de pedido
  late TextEditingController nomePagadorController;
  late TextEditingController cpfPagadorController;
  late TextEditingController celularPagadorController;
  late TextEditingController emailPagadorController;
  late TextEditingController motivoController;
  late TextEditingController numeroParcelasController;

  // Dados do pedido
  EnumTipoPedido? tipoPedidoSelecionado;
  Map<int, DTOPrecoInscricao?> precosInscricoes = {};
  double valorTotal = 0.0;
  
  late final Command1<void, String> pesquisarCPF;
  late final Command0<void> carregarFormasPagamento;
  late final Command1<DTOInscricao, DTOInscricao> incluirInscricao;
  late final Command1<void, DTOInscricao> atualizarInscricao;
  late final Command1<void, DTOFormaPagamento> selecionarFormaPagamento;
  late final Command0<void> validarEIncluirPedido;

  PedidoCadastroViewModel({
    required this.inscricoesWS,
    required this.precosWS,
    required this.formasPagamentoWS,
    required this.pedidosWS,
    required this.eventViewModel,
  }) {
    pesquisarCPF = Command1<void, String>(_pesquisarCPF);
    carregarFormasPagamento = Command0<void>(_carregarFormasPagamento);
    incluirInscricao = Command1<DTOInscricao, DTOInscricao>(_incluirInscricao);
    atualizarInscricao = Command1<void, DTOInscricao>(_atualizarInscricao); 
    selecionarFormaPagamento = Command1<void, DTOFormaPagamento>(_selecionarFormaPagamento);
    validarEIncluirPedido = Command0<void>(_validarEIncluirPedido);

    // Inicializar controllers
    nomePagadorController = TextEditingController();
    cpfPagadorController = TextEditingController();
    celularPagadorController = TextEditingController();
    emailPagadorController = TextEditingController();
    motivoController = TextEditingController();
    numeroParcelasController = TextEditingController();
  }

  @override
  void dispose() {
    nomePagadorController.dispose();
    cpfPagadorController.dispose();
    celularPagadorController.dispose();
    emailPagadorController.dispose();
    motivoController.dispose();
    numeroParcelasController.dispose();
    super.dispose();
  }

  Future<Result<void>> _pesquisarCPF(String cpf) async {
    try {
      pesquisaAtual = await inscricoesWS.pesquisar(eventViewModel.eventoEscolhido!.id!, cpf);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  Future<Result<void>> _carregarFormasPagamento() async {
    try {
      formasPagamento = await formasPagamentoWS.listar();
      if (formasPagamento.isNotEmpty) {
        formaSelecionada = formasPagamento.first;
      }
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  Future<Result<DTOInscricao>> _incluirInscricao(DTOInscricao inscricao) async {
    try {
      final resultado = await inscricoesWS.incluir(inscricao);
      inscricoesNoPedido.add(resultado);
      notifyListeners();
      return Result.ok(resultado);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  bool isInfantil(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month || (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      idade--;
    }
    return idade < eventViewModel.eventoEscolhido!.idadeMinimaAdulto;
  }

  double calcularValorInscricao(DTOInscricao inscricao, DTOPrecoInscricao preco, DTOFormaPagamento forma) {
     final valorForma = preco.valores.firstWhere((v) => v.forma.id == forma.id, orElse: () => preco.valores.first);
     return valorForma.preco;
  }

  Future<Result<void>> _selecionarFormaPagamento(DTOFormaPagamento forma) async {
    try {
      formaSelecionada = forma;
      precosInscricoes.clear();
      valorTotal = 0.0;

      // Buscar preços para cada inscrição baseado na data de nascimento
      for (var inscricao in inscricoesNoPedido) {
        if (inscricao.pessoa.dataNascimento != null) {
          final preco = await precosWS.obterPorIdade(
            eventViewModel.eventoEscolhido!.id!,
            inscricao.pessoa.dataNascimento!,
          );
          precosInscricoes[inscricao.id ?? 0] = preco;
          if (preco != null) {
            valorTotal += calcularValorInscricao(inscricao, preco, forma);
          }
        }
      }

      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  bool _validarCamposObrigatorios() {
    // Validar dados do pagador
    if (nomePagadorController.text.trim().isEmpty) return false;
    if (cpfPagadorController.text.trim().isEmpty) return false;
    if (celularPagadorController.text.trim().isEmpty) return false;
    if (emailPagadorController.text.trim().isEmpty) return false;

    // Validar tipo de pedido
    if (tipoPedidoSelecionado == null) return false;

    // Validações específicas por tipo
    if (tipoPedidoSelecionado == EnumTipoPedido.debito) {
      if (formaSelecionada == null) return false;
      if ((formaSelecionada?.nrParcelasMinima ?? 0) > 1 &&
          numeroParcelasController.text.trim().isEmpty) {
        return false;
      }
      if ((formaSelecionada?.nrParcelasMinima ?? 0) > 1) {
        final parcelas = int.tryParse(numeroParcelasController.text);
        if (parcelas == null ||
            parcelas < (formaSelecionada?.nrParcelasMinima ?? 0) ||
            parcelas > (formaSelecionada?.nrParcelasMaxima ?? 0)) {
          return false;
        }
      }
    } else {
      // Desconto ou Isenção
      if (motivoController.text.trim().isEmpty) return false;
    }

    return true;
  }

  Future<Result<void>> _validarEIncluirPedido() async {
    try {
      if (!_validarCamposObrigatorios()) {
        return Result.error(Exception('Preencha todos os campos obrigatórios'));
      }

      if (inscricoesNoPedido.isEmpty) {
        return Result.error(Exception('Adicione pelo menos uma inscrição'));
      }

      final pedido = DTOPedidoInclusao(
        idsInscricoes: inscricoesNoPedido.map((i) => i.id!).toList(),
        valor: tipoPedidoSelecionado == EnumTipoPedido.debito ? valorTotal : 0.0,
        tipo: tipoPedidoSelecionado!,
        nomePagador: nomePagadorController.text,
        cpfPagador: cpfPagadorController.text,
        celularPagador: celularPagadorController.text,
        emailPagador: emailPagadorController.text,
        idFormaPagamento: formaSelecionada?.id,
        motivo: tipoPedidoSelecionado == EnumTipoPedido.debito ? null : motivoController.text,
        numeroParcelas: (formaSelecionada?.nrParcelasMinima ?? 0) > 0
            ? int.tryParse(numeroParcelasController.text)
            : null,
      );

      await pedidosWS.incluir(pedido);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  double obterValorInscricao(DTOInscricao inscricao) {
    if (tipoPedidoSelecionado != EnumTipoPedido.debito) {
      return 0.0;
    }

    final preco = precosInscricoes[inscricao.id];
    if (preco == null || formaSelecionada == null) {
      return 0.0;
    }

    return calcularValorInscricao(inscricao, preco, formaSelecionada!);
  }

  Future<Result<void>> _atualizarInscricao(DTOInscricao inscricao) async {
    try {
      await inscricoesWS.atualizar(inscricao);
      inscricoesNoPedido.add(inscricao);
      
      notifyListeners();

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }
}
