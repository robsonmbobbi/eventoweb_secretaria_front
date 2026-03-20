import 'enum_tipo_pedido.dart';

class DTOPedidoInclusao {
  final List<int> idsInscricoes;
  final double valor;
  final EnumTipoPedido tipo;
  final int? idFormaPagamento;
  final String nomePagador;
  final String cpfPagador;
  final String celularPagador;
  final String emailPagador;
  final String? motivo;
  final int? numeroParcelas;

  DTOPedidoInclusao({
    required this.idsInscricoes,
    required this.valor,
    required this.tipo,
    required this.nomePagador,
    required this.cpfPagador,
    required this.celularPagador,
    required this.emailPagador,
    this.idFormaPagamento,
    this.motivo,
    this.numeroParcelas,
  });

  factory DTOPedidoInclusao.fromJson(Map<String, dynamic> json) => DTOPedidoInclusao(
        idsInscricoes: List<int>.from(json['idsInscricoes']),
        valor: (json['valor'] as num).toDouble(),
        tipo: EnumTipoPedido.values[json['tipo']],
        nomePagador: json['nomePagador'],
        cpfPagador: json['cpfPagador'],
        celularPagador: json['celularPagador'],
        emailPagador: json['emailPagador'],
        idFormaPagamento: json['idFormaPagamento'],
        motivo: json['motivo'],
        numeroParcelas: json['numeroParcelas'],
      );

  Map<String, dynamic> toJson() => {
        'idsInscricoes': idsInscricoes,
        'valor': valor,
        'tipo': tipo.index,
        'nomePagador': nomePagador,
        'cpfPagador': cpfPagador,
        'celularPagador': celularPagador,
        'emailPagador': emailPagador,
        'idFormaPagamento': idFormaPagamento,
        'motivo': motivo,
        'numeroParcelas': numeroParcelas,
      };
}
