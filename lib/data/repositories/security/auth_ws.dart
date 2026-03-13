import 'package:eventoweb_secretaria_front/data/models/security/auth_data.dart';
import 'package:eventoweb_secretaria_front/data/models/security/login_data.dart';
import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';

class AuthWS {

  final WSClient _httpClient;
  AuthWS(this._httpClient) ;

  Future<DTOAuthData?> authenticate(DTOLoginData loginData) async {

    var dataResponse = await _httpClient.put(path: "/autenticacao/autenticar", data: loginData.toJson());

      if (dataResponse == null || dataResponse == "") {
        return null;
      } else {
        return DTOAuthData.fromJson(dataResponse);
      }
  }
  
  Future<void> logout() async {    
    await _httpClient.delete(path: "/autenticacao");
  }  
}