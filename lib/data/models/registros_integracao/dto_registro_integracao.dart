import '../financeiro/enum_tipo_pagamento.dart';
import 'dto_registro_integracao_log.dart';
import 'enum_situacao_integracao.dart';

class DTORegistroIntegracao {
  final int id;
  final String identificacaoNoIntegrador;
  final EnumSituacaoIntegracao situacao;
  final EnumTipoPagamento tipo;
  final double valor;
  final DateTime dataRegistro;
  final int? numeroParcelas;
  final DateTime? dataConcluidoAbortado;
  final List<DTORegistroIntegracaoLog> logs;

  DTORegistroIntegracao({
    required this.id,
    required this.identificacaoNoIntegrador,
    required this.situacao,
    required this.tipo,
    required this.valor,
    required this.dataRegistro,
    this.numeroParcelas,
    this.dataConcluidoAbortado,
    required this.logs,
  });

  factory DTORegistroIntegracao.fromJson(Map<String, dynamic> json) => DTORegistroIntegracao(
        id: json['id'],
        identificacaoNoIntegrador: json['identificacaoNoIntegrador'] ?? '',
        situacao: EnumSituacaoIntegracao.values[json['situacao']],
        tipo: EnumTipoPagamento.values[json['tipo']],
        valor: (json['valor'] as num).toDouble(),
        dataRegistro: DateTime.parse(json['dataRegistro']),
        numeroParcelas: json['numeroParcelas'],
        dataConcluidoAbortado: json['dataConcluidoAbortado'] != null
            ? DateTime.parse(json['dataConcluidoAbortado'])
            : null,
        logs: (json['logs'] as List<dynamic>?)
                ?.map((e) => DTORegistroIntegracaoLog.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'identificacaoNoIntegrador': identificacaoNoIntegrador,
        'situacao': situacao.index,
        'tipo': tipo.index,
        'valor': valor,
        'dataRegistro': dataRegistro.toIso8601String(),
        'numeroParcelas': numeroParcelas,
        'dataConcluidoAbortado': dataConcluidoAbortado?.toIso8601String(),
        'logs': logs.map((e) => e.toJson()).toList(),
      };
}
