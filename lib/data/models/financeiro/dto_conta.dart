import 'enum_tipo_transacao.dart';

class DTOConta {
  final int id;
  final double valor;
  final DateTime dataVencimento;
  final bool liquidado;
  final double valorTotalTransacoes;
  final double valorTotalDesconto;
  final double valorTotalJuros;
  final double valorTotalMulta;
  final String? descricao;
  final DateTime dataCriado;
  final EnumTipoTransacao tipo;

  DTOConta({
    required this.id,
    required this.valor,
    required this.dataVencimento,
    required this.liquidado,
    required this.valorTotalTransacoes,
    required this.valorTotalDesconto,
    required this.valorTotalJuros,
    required this.valorTotalMulta,
    this.descricao,
    required this.dataCriado,
    required this.tipo,
  });

  factory DTOConta.fromJson(Map<String, dynamic> json) => DTOConta(
        id: json['id'],
        valor: json['valor'].toDouble(),
        dataVencimento: DateTime.parse(json['dataVencimento']),
        liquidado: json['liquidado'],
        valorTotalTransacoes: json['valorTotalTransacoes'].toDouble(),
        valorTotalDesconto: json['valorTotalDesconto'].toDouble(),
        valorTotalJuros: json['valorTotalJuros'].toDouble(),
        valorTotalMulta: json['valorTotalMulta'].toDouble(),
        descricao: json['descricao'],
        dataCriado: DateTime.parse(json['dataCriado']),
        tipo: EnumTipoTransacao.values[json['tipo']],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'valor': valor,
        'dataVencimento': dataVencimento.toIso8601String(),
        'liquidado': liquidado,
        'valorTotalTransacoes': valorTotalTransacoes,
        'valorTotalDesconto': valorTotalDesconto,
        'valorTotalJuros': valorTotalJuros,
        'valorTotalMulta': valorTotalMulta,
        'descricao': descricao,
        'dataCriado': dataCriado.toIso8601String(),
        'tipo': tipo.index,
      };
}
