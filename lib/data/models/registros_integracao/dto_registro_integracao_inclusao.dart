class DTORegistroIntegracaoInclusao {
  final int idConta;
  final int idFormaPagamento;
  final int idEvento;
  final double valor;
  final int? numeroParcelas;

  DTORegistroIntegracaoInclusao({
    required this.idConta,
    required this.idFormaPagamento,
    required this.idEvento,
    required this.valor,
    this.numeroParcelas,
  });

  Map<String, dynamic> toJson() => {
        'idConta': idConta,
        'idFormaPagamento': idFormaPagamento,
        'idEvento': idEvento,
        'valor': valor,
        'numeroParcelas': numeroParcelas,
      };
}
