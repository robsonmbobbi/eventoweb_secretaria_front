import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_forma_pagamento.dart';
import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';
import '../security/auth_repository.dart';

class FormasPagamentoWS {
  final WSClient _httpClient;
  final AuthRepository _authRepository;

  FormasPagamentoWS(this._httpClient, this._authRepository);

  Future<List<DTOFormaPagamento>> listar() async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/formaspagamento/listar");

    if (dataResponse == null || dataResponse == "") {
      return [];
    }
    return List<DTOFormaPagamento>.from(
        dataResponse.map((e) => DTOFormaPagamento.fromJson(e)));
  }
}
