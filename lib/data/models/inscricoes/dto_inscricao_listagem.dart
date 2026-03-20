import 'enum_situacao_inscricao.dart';
import 'enum_tipo_inscricao.dart';
import 'enum_tipo_participante.dart';

class DTOInscricaoListagem {
  final int? id;
  final String nome;
  final EnumTipoInscricao tipo;
  final EnumSituacaoInscricao situacao;
  final String? cidade;
  final String? uf;
  final bool dormira;
  final EnumTipoParticipante? tipoParticipante;

  DTOInscricaoListagem({
    this.id,
    required this.nome,
    required this.tipo,
    required this.situacao,
    this.cidade,
    this.uf,
    required this.dormira,
    this.tipoParticipante,
  });

  factory DTOInscricaoListagem.fromJson(Map<String, dynamic> json) => DTOInscricaoListagem(
        id: json['id'],
        nome: json['nome'],
        tipo: EnumTipoInscricao.values[json['tipo']],
        situacao: EnumSituacaoInscricao.values[json['situacao']],
        cidade: json['cidade'],
        uf: json['uf'],
        dormira: json['dormira'] ?? false,
        tipoParticipante: json['tipoParticipante'] != null
            ? EnumTipoParticipante.values[json['tipoParticipante']]
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'tipo': tipo.index,
        'situacao': situacao.index,
        'cidade': cidade,
        'uf': uf,
        'dormira': dormira,
        'tipoParticipante': tipoParticipante?.index,
      };
}
