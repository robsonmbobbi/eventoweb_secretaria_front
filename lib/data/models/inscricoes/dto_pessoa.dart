import 'enum_sexo.dart';

class DTOPessoa {
  final String nome;
  final DateTime? dataNascimento;
  final String cpf;
  final String? alergiaAlimentos;
  final String celular;
  final bool ehDiabetico;
  final bool ehVegetariano;
  final String email;
  final EnumSexo? sexo;
  final bool usaAdocanteDiariamente;
  final String? uf;
  final String? cidade ;

  DTOPessoa({
    required this.nome,
    required this.dataNascimento,
    required this.cpf,
    required this.celular,
    required this.email,
    this.alergiaAlimentos,
    this.ehDiabetico = false,
    this.ehVegetariano = false,
    this.sexo,
    this.usaAdocanteDiariamente = false,
    this.cidade,
    this.uf
  });

  factory DTOPessoa.fromJson(Map<String, dynamic> json) => DTOPessoa(
      nome: json['nome'],
      dataNascimento: json['dataNascimento'] == null ? null : DateTime.parse(json['dataNascimento']),
      cpf: json['cpf'],
      alergiaAlimentos: json['alergiaAlimentos'],
      celular: json['celular'],
      ehDiabetico: json['ehDiabetico'] ?? false,
      ehVegetariano: json['ehVegetariano'] ?? false,
      email: json['email'],
      sexo: json['sexo'] != null ? EnumSexo.values[json['sexo']] : null,
      usaAdocanteDiariamente: json['usaAdocanteDiariamente'] ?? false,
      cidade: json['cidade'],
      uf: json['uf']
    );

  Map<String, dynamic> toJson() => {
      'nome': nome,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'cpf': cpf,
      'alergiaAlimentos': alergiaAlimentos,
      'celular': celular,
      'ehDiabetico': ehDiabetico,
      'ehVegetariano': ehVegetariano,
      'email': email,
      'sexo': sexo?.index,
      'usaAdocanteDiariamente': usaAdocanteDiariamente,
      'uf': uf,
      'cidade': cidade
    };
}
