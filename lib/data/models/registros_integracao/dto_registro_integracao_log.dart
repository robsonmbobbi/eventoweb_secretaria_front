import 'enum_tipo_log.dart';

class DTORegistroIntegracaoLog {
  final String mensagem;
  final EnumTipoLog tipo;
  final DateTime data;
  final String? dados;

  DTORegistroIntegracaoLog({
    required this.mensagem,
    required this.tipo,
    required this.data,
    this.dados,
  });

  factory DTORegistroIntegracaoLog.fromJson(Map<String, dynamic> json) => DTORegistroIntegracaoLog(
        mensagem: json['mensagem'] ?? '',
        tipo: EnumTipoLog.values[json['tipo']],
        data: DateTime.parse(json['data']),
        dados: json['dados'],
      );

  Map<String, dynamic> toJson() => {
        'mensagem': mensagem,
        'tipo': tipo.index,
        'data': data.toIso8601String(),
        'dados': dados,
      };
}
