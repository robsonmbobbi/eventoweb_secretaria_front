import 'package:eventoweb_secretaria_front/data/models/security/login_data.dart';
import 'package:eventoweb_secretaria_front/data/models/users/user_objects.dart';
import 'package:eventoweb_secretaria_front/data/repositories/auth_repository.dart';
import 'package:eventoweb_secretaria_front/data/repositories/auth_ws.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final AuthWS _authWS;
  final AuthRepository _authRepository;
  bool? _isAuthenticated;

  AuthController(this._authWS, this._authRepository);

  Future<bool> login(String userName, String password) async {
    try {
      final authData = await _authWS.authenticate(
        DTOLoginData(username: userName, password: password),
      );

      if (authData == null) {
        return false;
      }

      await _authRepository.save(authData);
      _isAuthenticated = true;

      return true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.clear();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> get isAuthenticated async {
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }

    _isAuthenticated = (await _authRepository.get()) != null;
    return _isAuthenticated ?? false;
  }

  Future<DTOUsuario?> get user async {
    final authData = await _authRepository.get();
    return authData?.user;
  }
}
