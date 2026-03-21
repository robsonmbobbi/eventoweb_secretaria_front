import '../../models/registros_integracao/dto_registro_integracao.dart';
import '../../models/registros_integracao/dto_registro_integracao_inclusao.dart';
import '../security/auth_repository.dart';
import '../ws_client.dart';

class RegistrosIntegracaoWS {
  final WSClient _httpClient;
  final AuthRepository _authRepository;

  RegistrosIntegracaoWS(this._httpClient, this._authRepository);

  Future<List<DTORegistroIntegracao>> listarPorConta(int idConta) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/registrosintegracao/listar-conta/$idConta");

    if (dataResponse == null || dataResponse == "") {
      return [];
    } else {
      return List<DTORegistroIntegracao>.from(
          dataResponse.map((e) => DTORegistroIntegracao.fromJson(e)));
    }
  }

  Future<DTORegistroIntegracao> incluir(DTORegistroIntegracaoInclusao dto) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.post(path: "/registrosintegracao/incluir", data: dto.toJson());

    return DTORegistroIntegracao.fromJson(dataResponse);
  }
}
