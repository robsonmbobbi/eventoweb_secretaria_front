class DTOContaBancaria {
  final int id;
  final String nomeConta;

  DTOContaBancaria({
    required this.id,
    required this.nomeConta,
  });

  factory DTOContaBancaria.fromJson(Map<String, dynamic> json) => DTOContaBancaria(
        id: json['id'],
        nomeConta: json['nomeConta'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomeConta': nomeConta,
      };
}
