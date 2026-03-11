import 'package:eventoweb_secretaria_front/data/repositories/version_app_repository.dart';
import 'package:eventoweb_secretaria_front/domain/auth_controller.dart';
import 'package:flutter/material.dart';

class ShellViewModel extends ChangeNotifier {
  final VersionAppRepository _versionAppRepository;
  final AuthController _authController;


  ShellViewModel(
    this._authController,
    this._versionAppRepository,
  );

  Future<String> get versionApp => _versionAppRepository.getVersionApp();

  Future<void> logout() async {
    await _authController.logout();
    notifyListeners();
  }
}
