import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_preco_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';
import '../security/auth_repository.dart';

class PrecosInscricaoWS {
  final WSClient _httpClient;
  final AuthRepository _authRepository;

  PrecosInscricaoWS(this._httpClient, this._authRepository);

  Future<DTOPrecoInscricao?> obterPorIdade(int idEvento, DateTime dataNascimento) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    
    final dataNascimentoStr = dataNascimento.toIso8601String().split('T')[0];
    var dataResponse = await _httpClient.get(
      path: "/precosinscricao/evento/$idEvento/obter/nascimento/$dataNascimentoStr"
    );

    if (dataResponse == null || dataResponse == "") {
      return null;
    }
    return DTOPrecoInscricao.fromJson(dataResponse);
  }
}
