import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';

import '../../models/events/dto_evento.dart';

class EventsWS {

  final WSClient _httpClient;
  EventsWS(this._httpClient) ;

  Future<List<DTOEvento>> listAll() async {

    var dataResponse = await _httpClient.get(path: "/eventos/obter-todos");

      if (dataResponse == null || dataResponse == "") {
        return [];
      } else {
        return List<DTOEvento>.from(dataResponse.data.map((e) => DTOEvento.fromJson(e)));
      }
  }
}