class DTOLiquidacaoConta {
  final int idConta;
  final int idContaBancaria;
  final double valor;

  DTOLiquidacaoConta({
    required this.idConta,
    required this.idContaBancaria,
    required this.valor,
  });

  Map<String, dynamic> toJson() => {
        'idConta': idConta,
        'idContaBancaria': idContaBancaria,
        'valor': valor,
      };
}
