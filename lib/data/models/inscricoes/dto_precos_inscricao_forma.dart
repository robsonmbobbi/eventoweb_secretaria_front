import '../financeiro/dto_forma_pagamento.dart';

class DTOPrecosInscricaoForma {
  final DTOFormaPagamento forma;
  final double preco;

  DTOPrecosInscricaoForma({
    required this.forma,
    required this.preco,
  });

  factory DTOPrecosInscricaoForma.fromJson(Map<String, dynamic> json) =>
      DTOPrecosInscricaoForma(
        forma: DTOFormaPagamento.fromJson(json['forma']),
        preco: (json['preco'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'forma': forma.toJson(),
        'preco': preco,
      };
}
