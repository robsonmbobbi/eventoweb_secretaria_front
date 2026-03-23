import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_listagem.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_pesquisa_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';

import '../security/auth_repository.dart';

class InscricoesWS {

  final WSClient _httpClient;
  final AuthRepository _authRepository;
  InscricoesWS(this._httpClient, this._authRepository) ;

  Future<List<DTOInscricaoListagem>> listar(int idEvento, EnumSituacaoInscricao situacao) async {

    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/inscricoes/listar/evento/$idEvento/situacao/${situacao.index}");

      if (dataResponse == null || dataResponse == "") {
        return [];
      } else {
        return List<DTOInscricaoListagem>.from(dataResponse.map((e) => DTOInscricaoListagem.fromJson(e)));
      }
  }

  Future<DTOInscricao> obterPorId(int idInscricao) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/inscricoes/obter/$idInscricao");
    return DTOInscricao.fromJson(dataResponse);
  }

  Future<DTOInscricaoPesquisaPessoa> pesquisar(int idEvento, String cpf) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.get(path: "/inscricoes/pesquisar/evento/$idEvento/cpf/$cpf");

    return DTOInscricaoPesquisaPessoa.fromJson(dataResponse);
  }

  Future<DTOInscricao> incluir(DTOInscricao inscricao) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    var dataResponse = await _httpClient.post(path: "/inscricoes/incluir", data: inscricao.toJson());

    return DTOInscricao.fromJson(dataResponse);
  }

  Future<void> atualizar(DTOInscricao inscricao) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    await _httpClient.put(path: "/inscricoes/atualizar", data: inscricao.toJson());
  }

  Future<void> aceitar(int idInscricao) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    await _httpClient.put(path: "/inscricoes/aceitar/$idInscricao", data: null);
  }

  Future<void> rejeitar(int idInscricao) async {
    var authData = await _authRepository.get();
    _httpClient.setAuthToken(authData?.authToken ?? "");
    await _httpClient.put(path: "/inscricoes/rejeitar/$idInscricao", data: null);
  }
}
