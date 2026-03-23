import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_forma_pagamento.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_listagem.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/pedidos/dto_pedido.dart';
import 'package:eventoweb_secretaria_front/data/models/registros_integracao/dto_registro_integracao.dart';
import 'package:eventoweb_secretaria_front/data/models/registros_integracao/dto_registro_integracao_inclusao.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/contas_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/contas_bancarias_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/formas_pagamento_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/inscricoes_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/pedidos/pedidos_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/registros_integracao/registros_integracao_ws.dart';
import 'package:eventoweb_secretaria_front/utils/command.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/foundation.dart';

import '../../../event_shell/view_model/event_shell_viewmodel.dart';

class InscricoesListagemViewModel extends ChangeNotifier {
  EnumSituacaoInscricao? _situacaoEscolhida;

  final InscricoesWS inscricoesWS;
  final PedidosWS pedidosWS;
  final RegistrosIntegracaoWS registrosIntegracaoWS;
  final FormasPagamentoWS formasPagamentoWS;
  final ContasWS contasWS;
  final ContasBancariasWS contasBancariasWS;
  final EventShellViewModel eventViewModel;
  
  final List<DTOInscricaoListagem> inscricoes = [];
  
  DTOInscricaoListagem? _inscricaoListagemSelecionada;
  DTOInscricao? _inscricaoCompletaSelecionada;
  DTOPedido? _pedidoDaInscricaoSelecionada;
  List<DTORegistroIntegracao> _registrosIntegracao = [];
  List<DTOFormaPagamento> _formasPagamento = [];

  late final Command1<void, EnumSituacaoInscricao> escolherSituacao;
  late final Command1<void, DTOInscricaoListagem?> selecionarInscricao;
  late final Command1<void, DTORegistroIntegracaoInclusao> incluirRegistroIntegracao;
  late final Command0<void> carregarFormasPagamento;
  late final Command1<void, DTOInscricao> atualizarInscricao;
  late final Command1<void, int> aceitarInscricao;
  late final Command1<void, int> rejeitarInscricao;

  EnumSituacaoInscricao? get situacaoEscolhida => _situacaoEscolhida;
  DTOInscricaoListagem? get inscricaoSelecionada => _inscricaoListagemSelecionada;
  DTOInscricao? get inscricaoCompletaSelecionada => _inscricaoCompletaSelecionada;
  DTOPedido? get pedidoDaInscricaoSelecionada => _pedidoDaInscricaoSelecionada;
  List<DTORegistroIntegracao> get registrosIntegracao => _registrosIntegracao;
  List<DTOFormaPagamento> get formasPagamento => _formasPagamento;

  InscricoesListagemViewModel({
    required this.inscricoesWS, 
    required this.pedidosWS,
    required this.registrosIntegracaoWS,
    required this.formasPagamentoWS,
    required this.contasWS,
    required this.contasBancariasWS,
    required this.eventViewModel,
  }) {
    escolherSituacao = Command1<void, EnumSituacaoInscricao>(_escolherSituacao);
    selecionarInscricao = Command1<void, DTOInscricaoListagem?>(_selecionarInscricao);
    incluirRegistroIntegracao = Command1<void, DTORegistroIntegracaoInclusao>(_incluirRegistroIntegracao);
    carregarFormasPagamento = Command0<void>(_carregarFormasPagamento);
    atualizarInscricao = Command1<void, DTOInscricao>(_atualizarInscricao);
    aceitarInscricao = Command1<void, int>(_aceitarInscricao);
    rejeitarInscricao = Command1<void, int>(_rejeitarInscricao);
  }

  Future<Result<void>> _escolherSituacao(EnumSituacaoInscricao novaSituacao) async {
    if (novaSituacao == _situacaoEscolhida) {
      return Result.ok(null);
    }

    try {
      inscricoes
          ..clear()
          ..addAll(await inscricoesWS.listar(eventViewModel.eventoEscolhido!.id!, novaSituacao));

      _situacaoEscolhida = novaSituacao;
      _inscricaoListagemSelecionada = null;
      _inscricaoCompletaSelecionada = null;
      _pedidoDaInscricaoSelecionada = null;
      _registrosIntegracao = [];
      
      notifyListeners();

      return Result.ok(null);
    }
    on Exception catch(ex) {
      return Result.error(ex);
    }
  }

  Future<Result<void>> _selecionarInscricao(DTOInscricaoListagem? inscricao) async {
    _inscricaoListagemSelecionada = inscricao;
    _inscricaoCompletaSelecionada = null;
    _pedidoDaInscricaoSelecionada = null;
    _registrosIntegracao = [];
    
    if (inscricao != null && inscricao.id != null) {
      try {
        _inscricaoCompletaSelecionada = await inscricoesWS.obterPorId(inscricao.id!);
        _pedidoDaInscricaoSelecionada = await pedidosWS.obterPorInscricao(inscricao.id!);
        
        if (_pedidoDaInscricaoSelecionada != null) {
          _registrosIntegracao = await registrosIntegracaoWS.listarPorConta(_pedidoDaInscricaoSelecionada!.conta.id);
        }
      } catch (e) {
        print("Erro ao carregar detalhes: $e");
      }
    }
    
    notifyListeners();
    return Result.ok(null);
  }

  Future<Result<void>> _incluirRegistroIntegracao(DTORegistroIntegracaoInclusao dto) async {
    try {
      await registrosIntegracaoWS.incluir(dto);
      // Recarregar registros após inclusão
      if (_pedidoDaInscricaoSelecionada != null) {
        _registrosIntegracao = await registrosIntegracaoWS.listarPorConta(_pedidoDaInscricaoSelecionada!.conta.id);
      }
      notifyListeners();
      return Result.ok(null);
    } on Exception catch (ex) {
      return Result.error(ex);
    }
  }

  Future<Result<void>> _carregarFormasPagamento() async {
    try {
      _formasPagamento = await formasPagamentoWS.listar();
      notifyListeners();
      return Result.ok(null);
    } on Exception catch (ex) {
      return Result.error(ex);
    }
  }

  Future<Result<void>> _atualizarInscricao(DTOInscricao inscricao) async {
    try {
      await inscricoesWS.atualizar(inscricao);
      _inscricaoCompletaSelecionada = inscricao;
      
      // Atualizar na lista de listagem também
      final index = inscricoes.indexWhere((element) => element.id == inscricao.id);
      if (index != -1) {
        inscricoes[index] = DTOInscricaoListagem(
          id: inscricao.id,
          nome: inscricao.pessoa.nome,
          tipo: inscricao.tipo,
          situacao: inscricao.situacao!,
          cidade: inscricao.pessoa.cidade,
          uf: inscricao.pessoa.uf,
          dormira: inscricao.dormeEvento,
          tipoParticipante: inscricao.tipoParticipante,
        );
      }

      notifyListeners();
      return Result.ok(null);
    } on Exception catch (ex) {
      return Result.error(ex);
    }
  }

  Future<Result<void>> _aceitarInscricao(int idInscricao) async {
    try {
      await inscricoesWS.aceitar(idInscricao);
      
      // Recarregar lista de inscrições no grid
      if (_situacaoEscolhida != null) {
        inscricoes
            ..clear()
            ..addAll(await inscricoesWS.listar(
              eventViewModel.eventoEscolhido!.id!, 
              _situacaoEscolhida!
            ));
      }
      
      // Limpar seleção
      _inscricaoListagemSelecionada = null;
      _inscricaoCompletaSelecionada = null;
      _pedidoDaInscricaoSelecionada = null;
      _registrosIntegracao = [];
      
      notifyListeners();
      return Result.ok(null);
    } on Exception catch (ex) {
      return Result.error(ex);
    }
  }

  Future<Result<void>> _rejeitarInscricao(int idInscricao) async {
    try {
      await inscricoesWS.rejeitar(idInscricao);
      
      // Recarregar lista de inscrições no grid
      if (_situacaoEscolhida != null) {
        inscricoes
            ..clear()
            ..addAll(await inscricoesWS.listar(
              eventViewModel.eventoEscolhido!.id!, 
              _situacaoEscolhida!
            ));
      }
      
      // Limpar seleção
      _inscricaoListagemSelecionada = null;
      _inscricaoCompletaSelecionada = null;
      _pedidoDaInscricaoSelecionada = null;
      _registrosIntegracao = [];
      
      notifyListeners();
      return Result.ok(null);
    } on Exception catch (ex) {
      return Result.error(ex);
    }
  }
}
