import '../financeiro/enum_status_transacao.dart';
import '../financeiro/enum_tipo_pagamento.dart';

class DTOConsultaRegistroIntegracao {
  final EnumTipoPagamento tipoTransacao;
  final EnumStatusTransacao status;
  final String? imagemQRCodePixBase64;
  final String? pixCopiaECola;
  final String? linkPagamento;
  final double valor;

  DTOConsultaRegistroIntegracao({
    required this.tipoTransacao,
    required this.status,
    this.imagemQRCodePixBase64,
    this.pixCopiaECola,
    this.linkPagamento,
    required this.valor,
  });

  factory DTOConsultaRegistroIntegracao.fromJson(Map<String, dynamic> json) =>
      DTOConsultaRegistroIntegracao(
        tipoTransacao: EnumTipoPagamento.values[json['tipoTransacao']],
        status: EnumStatusTransacao.values[json['status']],
        imagemQRCodePixBase64: json['imagemQRCodePixBase64'],
        pixCopiaECola: json['pixCopiaECola'],
        linkPagamento: json['linkPagamento'],
        valor: (json['valor'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'tipoTransacao': tipoTransacao.index,
        'status': status.index,
        'imagemQRCodePixBase64': imagemQRCodePixBase64,
        'pixCopiaECola': pixCopiaECola,
        'linkPagamento': linkPagamento,
        'valor': valor,
      };
}
