import '../../models/pedidos/dto_pedido.dart';
import '../../models/pedidos/dto_pedido_inclusao.dart';
import '../../models/pedidos/dto_resultado_pedido.dart';
import '../security/auth_repository.dart';
import '../ws_client.dart';

class PedidosWS {
  final WSClient _httpClient;
  final AuthRepository _authRepository;

  PedidosWS(this._httpClient, this._authRepository);

  Future<DTOPedido> obterPorInscricao(int idInscricao) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/pedidos/obter-por-inscricao/$idInscricao");

    return DTOPedido.fromJson(dataResponse);
  }

  Future<DTOResultadoPedido> incluir(DTOPedidoInclusao pedidoInclusao) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.post(
      path: "/pedidos/incluir",
      data: pedidoInclusao.toJson(),
    );

    return DTOResultadoPedido.fromJson(dataResponse);
  }
}