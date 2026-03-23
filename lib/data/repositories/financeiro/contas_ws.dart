import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';
import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_liquidacao_conta.dart';
import '../security/auth_repository.dart';

class ContasWS {
  final WSClient _httpClient;
  final AuthRepository _authRepository;

  ContasWS(this._httpClient, this._authRepository);

  Future<void> liquidar(DTOLiquidacaoConta dto) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    
    await _httpClient.post(
      path: "/contas/liquidar", 
      data: dto.toJson()
    );
  }
}
