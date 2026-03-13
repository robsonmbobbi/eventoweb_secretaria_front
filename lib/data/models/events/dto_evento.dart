/// Representa um evento disponível para inscrição
class DTOEvento {

  DTOEvento({
    this.id,
    required this.nome,
    required this.dataInicialInscricao,
    required this.dataFinalInscricao,
    required this.dataInicialRealizacao,
    required this.dataFinalRealizacao,
    required this.idadeMinimaAdulto,
    this.logotipo,
    this.regulamento,
  });

  factory DTOEvento.fromJson(Map<String, dynamic> json) => DTOEvento(
      id: json['id'],
      nome: json['nome'],
      dataInicialInscricao: DateTime.parse(json['dataInicialInscricao']),
      dataFinalInscricao: DateTime.parse(json['dataFinalInscricao']),
      dataInicialRealizacao: DateTime.parse(json['dataInicialRealizacao']),
      dataFinalRealizacao: DateTime.parse(json['dataFinalRealizacao']),
      logotipo: json['logotipo'],
      idadeMinimaAdulto: json['idadeMinimaAdulto'],
      regulamento: json['regulamento'],
    );
  final int? id;
  final String nome;
  final DateTime dataInicialInscricao;
  final DateTime dataFinalInscricao;
  final DateTime dataInicialRealizacao;
  final DateTime dataFinalRealizacao;
  final String? logotipo;
  final int idadeMinimaAdulto;
  final String? regulamento;

  Map<String, dynamic> toJson() => {
      'id': id,
      'nome': nome,
      'dataInicialInscricao': dataInicialInscricao.toIso8601String(),
      'dataFinalInscricao': dataFinalInscricao.toIso8601String(),
      'dataInicialRealizacao': dataInicialRealizacao.toIso8601String(),
      'dataFinalRealizacao': dataFinalRealizacao.toIso8601String(),
      'logotipo': logotipo,
      'idadeMinimaAdulto': idadeMinimaAdulto,
      'regulamento': regulamento,
    };
}
