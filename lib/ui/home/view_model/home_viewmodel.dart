import 'package:eventoweb_secretaria_front/data/models/events/dto_evento.dart';
import 'package:eventoweb_secretaria_front/data/repositories/events/events_ws.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/command.dart';

class HomeViewModel extends ChangeNotifier{

  HomeViewModel(this._eventsWS) {
    comandoListarTodosEventos = Command0(_listarTodosEventos);
  }

  final EventsWS _eventsWS;

  final List<DTOEvento> eventos = [];
  late final Command0<void> comandoListarTodosEventos;

  Future<Result<void>> _listarTodosEventos() async {
    try {
      eventos
        ..clear()
        ..addAll(await _eventsWS.listAll());

      notifyListeners();

      return Result<void>.ok(null);
    }
    on Exception catch (ex) {
      return Result<void>.error(ex);
    }
  }
}