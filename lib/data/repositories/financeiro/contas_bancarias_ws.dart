import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_conta_bancaria.dart';
import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';
import '../security/auth_repository.dart';

class ContasBancariasWS {
  final WSClient _httpClient;
  final AuthRepository _authRepository;

  ContasBancariasWS(this._httpClient, this._authRepository);

  Future<List<DTOContaBancaria>> listar() async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/contasbancarias/listar");

    if (dataResponse == null || dataResponse == "") {
      return [];
    }
    return List<DTOContaBancaria>.from(
        dataResponse.map((e) => DTOContaBancaria.fromJson(e)));
  }
}
