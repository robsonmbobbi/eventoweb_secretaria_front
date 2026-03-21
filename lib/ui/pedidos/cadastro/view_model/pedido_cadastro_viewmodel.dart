import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_forma_pagamento.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_pesquisa_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_preco_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_pesquisa_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/formas_pagamento_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/inscricoes_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/precos_inscricao_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/pedidos/pedidos_ws.dart';
import 'package:eventoweb_secretaria_front/utils/command.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/foundation.dart';
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
  
  late final Command1<void, String> pesquisarCPF;
  late final Command0<void> carregarFormasPagamento;

  PedidoCadastroViewModel({
    required this.inscricoesWS,
    required this.precosWS,
    required this.formasPagamentoWS,
    required this.pedidosWS,
    required this.eventViewModel,
  }) {
    pesquisarCPF = Command1<void, String>(_pesquisarCPF);
    carregarFormasPagamento = Command0<void>(_carregarFormasPagamento);
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

  void adicionarInscricao(DTOInscricao inscricao) {
    inscricoesNoPedido.add(inscricao);
    notifyListeners();
  }
}
