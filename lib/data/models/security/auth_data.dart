import 'package:eventoweb_secretaria_front/data/models/users/user_objects.dart';

class DTOAuthData {
  DTOUsuario user;
  DateTime validate;
  String authToken;

  DTOAuthData({
    required this.user,
    required this.validate,
    required this.authToken,
  });

  factory DTOAuthData.fromJson(Map<String, dynamic> json) {
    return DTOAuthData(
      user: DTOUsuario.fromJson(json['usuario']),
      validate: DateTime.parse(json['validade']),
      authToken: json['tokenAutenticacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': user.toJson(),
      'validade': validate.toIso8601String(),
      'tokenAutenticacao': authToken,
    };
  }
}
