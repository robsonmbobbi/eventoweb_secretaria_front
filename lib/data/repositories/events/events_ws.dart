import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';

import '../../models/events/dto_evento.dart';
import '../security/auth_repository.dart';

class EventsWS {

  final WSClient _httpClient;
  final AuthRepository _authRepository;
  EventsWS(this._httpClient, this._authRepository) ;

  Future<List<DTOEvento>> listAll() async {

    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/eventos/obter-todos");

      if (dataResponse == null || dataResponse == "") {
        return [];
      } else {
        return List<DTOEvento>.from(dataResponse.map((e) => DTOEvento.fromJson(e)));
      }
  }
}