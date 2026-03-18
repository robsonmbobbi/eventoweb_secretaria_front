import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/inscricoes_ws.dart';
import 'package:eventoweb_secretaria_front/utils/command.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/models/inscricoes/dto_inscricao.dart';
import '../../../event_shell/view_model/event_shell_viewmodel.dart';

class InscricoesListagemViewModel extends ChangeNotifier {
  EnumSituacaoInscricao? _situacaoEscolhida = null;

  final InscricoesWS inscricoesWS;
  final EventShellViewModel eventViewModel;
  final List<DTOInscricao> inscricoes = [];

  late final Command1<void, EnumSituacaoInscricao> escolherSituacao;
  EnumSituacaoInscricao? get situacaoEscolhida => _situacaoEscolhida;

  InscricoesListagemViewModel({required this.inscricoesWS, required this.eventViewModel}) {
    escolherSituacao = Command1<void, EnumSituacaoInscricao>(_escolherSituacao);
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
      notifyListeners();

      return Result.ok(null);
    }
    on Exception catch(ex) {
      return Result.error(ex);
    }
  }
}