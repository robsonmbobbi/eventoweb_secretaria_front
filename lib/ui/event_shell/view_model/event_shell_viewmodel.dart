import 'package:eventoweb_secretaria_front/data/models/events/dto_evento.dart';
import 'package:eventoweb_secretaria_front/utils/command.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/foundation.dart';

import '../../home/view_model/home_viewmodel.dart';

class EventShellViewModel extends ChangeNotifier {
  late final Command1<void, int> atribuirEventoComando;
  late final HomeViewModel _homeViewModel;
  DTOEvento? _eventoEscolhido;

  DTOEvento? get eventoEscolhido => _eventoEscolhido;

  EventShellViewModel(this._homeViewModel) {
    atribuirEventoComando = Command1<void, int>(_atribuirEvento);
  }

  Future<Result<void>> _atribuirEvento(int idEvento) async {
    try {
      _eventoEscolhido =
          _homeViewModel.eventos.firstWhere((e) => e.id == idEvento);
      notifyListeners();

      return Result.ok(null);
    }
    on Exception catch(ex) {
      return Result.error(ex);
    }
  }
}