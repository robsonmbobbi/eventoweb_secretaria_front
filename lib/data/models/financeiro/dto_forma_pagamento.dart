import 'enum_tipo_pagamento.dart';

class DTOFormaPagamento {
  final int id;
  final String nome;
  final int nrParcelasMinima;
  final int nrParcelasMaxima;
  final EnumTipoPagamento tipo;

  DTOFormaPagamento({
    required this.id,
    required this.nome,
    required this.nrParcelasMinima,
    required this.nrParcelasMaxima,
    required this.tipo,
  });

  factory DTOFormaPagamento.fromJson(Map<String, dynamic> json) => DTOFormaPagamento(
        id: json['id'],
        nome: json['nome'],
        nrParcelasMinima: json['nrParcelasMinima'],
        nrParcelasMaxima: json['nrParcelasMaxima'],
        tipo: EnumTipoPagamento.values[json['tipo']],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'nrParcelasMinima': nrParcelasMinima,
        'nrParcelasMaxima': nrParcelasMaxima,
        'tipo': tipo.index,
      };
}
