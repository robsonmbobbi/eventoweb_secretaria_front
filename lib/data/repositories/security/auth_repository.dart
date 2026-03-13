import 'dart:convert';

import 'package:eventoweb_secretaria_front/data/models/security/auth_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const _authKey = 'AUTH_KEY';
  
  Future<DTOAuthData?> get() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var authJson = sharedPreferences.getString(_authKey);
    if (authJson == null) {
      return null;
    }
    else  {
      return DTOAuthData.fromJson(jsonDecode(authJson));
    }
  }

  Future<void> save(DTOAuthData authData) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var authJson = jsonEncode(authData.toJson());
    await sharedPreferences.setString(_authKey, authJson);
  }

  Future<void> clear() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(_authKey);
  }
}