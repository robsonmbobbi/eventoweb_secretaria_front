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
      login: json['login'] as String,
      nome: json['nome'] as String,
      ehAdministrador: json['ehAdministrador'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'login': login,
    'nome': nome,
    'ehAdministrador': ehAdministrador
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
      login: json['login'] as String,
      nome: json['nome'] as String,
      ehAdministrador: json['ehAdministrador'] as bool,
      senha: json['senha'] as String,
      repeticaoSenha: json['repeticaoSenha'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'senha': senha,
    'repeticaoSenha': repeticaoSenha,
  };
}
