import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';

import '../../models/inscricoes/dto_inscricao.dart';
import '../security/auth_repository.dart';

class InscricoesWS {

  final WSClient _httpClient;
  final AuthRepository _authRepository;
  InscricoesWS(this._httpClient, this._authRepository) ;

  Future<List<DTOInscricao>> listar(int idEvento, EnumSituacaoInscricao situacao) async {

    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/inscricoes/listar/evento/$idEvento/situacao/${situacao.index}");

      if (dataResponse == null || dataResponse == "") {
        return [];
      } else {
        return List<DTOInscricao>.from(dataResponse.map((e) => DTOInscricao.fromJson(e)));
      }
  }
}