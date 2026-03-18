/// Representa um responsável por um inscrito (para menores)
class DTOResponsavel {
  final int idInscricao;
  final String? cpf;
  final String? nome;

  DTOResponsavel({
    required this.idInscricao,
    this.cpf,
    this.nome,
  });

  factory DTOResponsavel.fromJson(Map<String, dynamic> json) => DTOResponsavel(
      idInscricao: json['idInscricao'],
      cpf: json['cpf'],
      nome: json['nome'],
    );

  Map<String, dynamic> toJson() => {
      'idInscricao': idInscricao,
      'cpf': cpf,
      'nome': nome,
    };

  DTOResponsavel copyWith({
    int? idInscricao,
    String? cpf,
    String? nome,
  }) => DTOResponsavel(
      idInscricao: idInscricao ?? this.idInscricao,
      cpf: cpf ?? this.cpf,
      nome: nome ?? this.nome,
    );
}
