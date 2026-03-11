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
      user: DTOUsuario.fromJson(json['Usuario']),
      validate: DateTime.parse(json['Validade']),
      authToken: json['TokenAutenticacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Usuario': user.toJson(),
      'Validade': validate.toIso8601String(),
      'TokenAutenticacao': authToken,
    };
  }
}
