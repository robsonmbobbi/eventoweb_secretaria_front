import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';
import '../security/auth_repository.dart';

class ContasWS {
  final WSClient _httpClient;
  final AuthRepository _authRepository;

  ContasWS(this._httpClient, this._authRepository);

  Future<void> liquidar(int idConta, double valorPago, double valorDesconto, double valorAcrescimo) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    
    await _httpClient.post(
      path: "/contas/$idConta/liquidar", 
      data: {
        'valorPago': valorPago,
        'valorDesconto': valorDesconto,
        'valorAcrescimo': valorAcrescimo,
      }
    );
  }
}
