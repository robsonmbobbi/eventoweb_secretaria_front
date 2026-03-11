import 'package:eventoweb_secretaria_front/data/repositories/version_app_repository.dart';
import 'package:eventoweb_secretaria_front/domain/auth_controller.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {

  final AuthController _authController;
  final VersionAppRepository _versionAppRepository;

  bool _processing = false;
  String _userName = '';
  String _password = '';
  Object? _error;
  String? _validationMessages;

  LoginViewModel(this._authController, this._versionAppRepository);

  bool get processing => _processing;
  String get userName => _userName;
  String get password => _password;
  Future<String> get versionApp => _versionAppRepository.getVersionApp();
  Object? get error => _error;
  String? get validationMessages => _validationMessages;

  Future login(String? userName, String? password) async {
    _processing = true;
    
    _userName = userName ?? '';
    _password = password ?? '';

    _error = null;
    _validationMessages = null; 

    notifyListeners();   

    try {
      if (!await _authController.login(_userName, _password)) {
        _validationMessages = "Usuário ou senha inválidos!";
      }
    }
    catch (e) {      
      _error = e;
    }
    finally {
      _processing = false;
      _password = '';
      
      notifyListeners();
    }
  }
}