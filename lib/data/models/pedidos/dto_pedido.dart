import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_listagem.dart';

import '../financeiro/dto_conta.dart';
import '../financeiro/dto_forma_pagamento.dart';
import '../inscricoes/dto_pessoa.dart';
import 'enum_tipo_pedido.dart';

class DTOPedido {
  final int id;
  final double valor;
  final EnumTipoPedido tipo;
  final DTOFormaPagamento? formaPagamento;
  final List<DTOInscricaoListagem> inscricoes;
  final DTOPessoa pagador;
  final DTOConta conta;

  DTOPedido({
    required this.id,
    required this.valor,
    required this.tipo,
    this.formaPagamento,
    required this.inscricoes,
    required this.pagador,
    required this.conta,
  });

  factory DTOPedido.fromJson(Map<String, dynamic> json) => DTOPedido(
        id: json['id'],
        valor: json['valor'].toDouble(),
        tipo: EnumTipoPedido.values[json['tipo']],
        formaPagamento: json['formaPagamento'] != null
            ? DTOFormaPagamento.fromJson(json['formaPagamento'])
            : null,
        inscricoes: List<DTOInscricaoListagem>.from(
            json['inscricoes'].map((x) => DTOInscricaoListagem.fromJson(x))),
        pagador: DTOPessoa.fromJson(json['pagador']),
        conta: DTOConta.fromJson(json['conta']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'valor': valor,
        'tipo': tipo.index,
        'formaPagamento': formaPagamento?.toJson(),
        'inscricoes': List<dynamic>.from(inscricoes.map((x) => x.toJson())),
        'pagador': pagador.toJson(),
        'conta': conta.toJson(),
      };
}
