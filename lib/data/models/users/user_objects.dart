class DTOUsuario {
  final String login;
  final String nome;
  final bool ehAdministrador;

  DTOUsuario({
    required this.login,
    required this.nome,
    required this.ehAdministrador
  });

  factory DTOUsuario.fromJson(Map<String, dynamic> json) {
    return DTOUsuario(
      login: json['Login'] as String,
      nome: json['Nome'] as String,
      ehAdministrador: json['EhAdministrador'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'Login': login,
    'Nome': nome,
    'EhAdministrador': ehAdministrador
  };
}

class DTOUsuarioInclusao extends DTOUsuario {
  final String senha;
  final String repeticaoSenha;

  DTOUsuarioInclusao({
    required super.login,
    required super.nome,
    required super.ehAdministrador,
    required this.senha,
    required this.repeticaoSenha
  });

  factory DTOUsuarioInclusao.fromJson(Map<String, dynamic> json) {
    return DTOUsuarioInclusao(
      login: json['Login'] as String,
      nome: json['Nome'] as String,
      ehAdministrador: json['EhAdministrador'] as bool,
      senha: json['Senha'] as String,
      repeticaoSenha: json['RepeticaoSenha'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'Senha': senha,
    'RepeticaoSenha': repeticaoSenha,
  };
}
