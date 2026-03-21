import 'dto_precos_inscricao_forma.dart';

class DTOPrecoInscricao {
  final int id;
  final int idadeMax;
  final List<DTOPrecosInscricaoForma> valores;

  DTOPrecoInscricao({
    required this.id,
    required this.idadeMax,
    required this.valores,
  });

  factory DTOPrecoInscricao.fromJson(Map<String, dynamic> json) => DTOPrecoInscricao(
        id: json['id'],
        idadeMax: json['idadeMax'],
        valores: (json['valores'] as List)
            .map((v) => DTOPrecosInscricaoForma.fromJson(v))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'idadeMax': idadeMax,
        'valores': valores.map((v) => v.toJson()).toList(),
      };
}
