class DTOLoginData {
  String username;
  String password;

  DTOLoginData({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'Login': username,
      'Senha': password,
    };
  }
}