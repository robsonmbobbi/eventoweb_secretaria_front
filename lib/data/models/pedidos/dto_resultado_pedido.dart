import '../financeiro/enum_status_transacao.dart';
import '../financeiro/enum_tipo_pagamento.dart';
import 'enum_tipo_pedido.dart';

class DTOResultadoPedido {
  final int idPedido;
  final double valor;
  final EnumTipoPedido tipo;
  final int? idFormaPagamento;
  final DTODebitoPedido? debito;

  DTOResultadoPedido({
    required this.idPedido,
    required this.valor,
    required this.tipo,
    this.idFormaPagamento,
    this.debito,
  });

  factory DTOResultadoPedido.fromJson(Map<String, dynamic> json) => DTOResultadoPedido(
        idPedido: json['idPedido'],
        valor: (json['valor'] as num).toDouble(),
        tipo: EnumTipoPedido.values[json['tipo']],
        idFormaPagamento: json['idFormaPagamento'],
        debito: json['debito'] != null ? DTODebitoPedido.fromJson(json['debito']) : null,
      );

  Map<String, dynamic> toJson() => {
        'idPedido': idPedido,
        'valor': valor,
        'tipo': tipo.index,
        'idFormaPagamento': idFormaPagamento,
        'debito': debito?.toJson(),
      };
}

class DTODebitoPedido {
  final EnumTipoPagamento tipoTransacao;
  final EnumStatusTransacao status;
  final String? imagemQRCodePixBase64;
  final String? pixCopiaECola;

  DTODebitoPedido({
    required this.tipoTransacao,
    required this.status,
    this.imagemQRCodePixBase64,
    this.pixCopiaECola,
  });

  factory DTODebitoPedido.fromJson(Map<String, dynamic> json) => DTODebitoPedido(
        tipoTransacao: EnumTipoPagamento.values[json['tipoTransacao']],
        status: EnumStatusTransacao.values[json['status']],
        imagemQRCodePixBase64: json['imagemQRCodePixBase64'],
        pixCopiaECola: json['pixCopiaECola'],
      );

  Map<String, dynamic> toJson() => {
        'tipoTransacao': tipoTransacao.index,
        'status': status.index,
        'imagemQRCodePixBase64': imagemQRCodePixBase64,
        'pixCopiaECola': pixCopiaECola,
      };
}
