import 'dto_pessoa.dart';
import 'dto_responsavel.dart';
import 'enum_situacao_inscricao.dart';
import 'enum_tipo_inscricao.dart';
import 'enum_tipo_participante.dart';

/// Representa uma inscrição em um evento
class DTOInscricao {
  final int? id;
  final EnumTipoInscricao tipo;
  final int idEvento;
  final String? instituicoesEspiritasFrequenta;
  final bool dormeEvento;
  final String? nomeCracha;
  final String? observacoes;
  final DTOPessoa pessoa;
  final DTOResponsavel? responsavel1;
  final DTOResponsavel? responsavel2;
  final EnumSituacaoInscricao? situacao;
  final EnumTipoParticipante? tipoParticipante;

  DTOInscricao({
    required this.tipo,
    required this.idEvento,
    required this.pessoa,
    this.id,
    this.instituicoesEspiritasFrequenta,
    this.dormeEvento = true,
    this.nomeCracha,
    this.observacoes,
    this.responsavel1,
    this.responsavel2,
    this.situacao,
    this.tipoParticipante,
  });

  factory DTOInscricao.fromJson(Map<String, dynamic> json) => DTOInscricao(
        id: json['id'],
        tipo: EnumTipoInscricao.values[json['tipo']],
        idEvento: json['idEvento'],
        instituicoesEspiritasFrequenta: json['instituicoesEspiritasFrequenta'],
        dormeEvento: json['dormeEvento'] ?? true,
        nomeCracha: json['nomeCracha'],
        observacoes: json['observacoes'],
        pessoa: DTOPessoa.fromJson(json['pessoa']),
        responsavel1: json['responsavel1'] != null
            ? DTOResponsavel.fromJson(json['responsavel1'])
            : null,
        responsavel2: json['responsavel2'] != null
            ? DTOResponsavel.fromJson(json['responsavel2'])
            : null,
        situacao: json['situacao'] != null
            ? EnumSituacaoInscricao.values[json['situacao']]
            : null,
        tipoParticipante: json['tipoParticipante'] != null
            ? EnumTipoParticipante.values[json['tipoParticipante']]
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.index,
        'idEvento': idEvento,
        'instituicoesEspiritasFrequenta': instituicoesEspiritasFrequenta,
        'dormeEvento': dormeEvento,
        'nomeCracha': nomeCracha,
        'observacoes': observacoes,
        'pessoa': pessoa.toJson(),
        'responsavel1': responsavel1?.toJson(),
        'responsavel2': responsavel2?.toJson(),
        'situacao': situacao?.index,
        'tipoParticipante': tipoParticipante?.index,
      };

  DTOInscricao copyWith({
    int? id,
    EnumTipoInscricao? tipo,
    int? idEvento,
    String? instituicoesEspiritasFrequenta,
    bool? dormeEvento,
    String? nomeCracha,
    String? observacoes,
    DTOPessoa? pessoa,
    DTOResponsavel? responsavel1,
    DTOResponsavel? responsavel2,
    EnumSituacaoInscricao? situacao,
    EnumTipoParticipante? tipoParticipante,
  }) =>
      DTOInscricao(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        idEvento: idEvento ?? this.idEvento,
        instituicoesEspiritasFrequenta:
            instituicoesEspiritasFrequenta ?? this.instituicoesEspiritasFrequenta,
        dormeEvento: dormeEvento ?? this.dormeEvento,
        nomeCracha: nomeCracha ?? this.nomeCracha,
        observacoes: observacoes ?? this.observacoes,
        pessoa: pessoa ?? this.pessoa,
        responsavel1: responsavel1 ?? this.responsavel1,
        responsavel2: responsavel2 ?? this.responsavel2,
        situacao: situacao ?? this.situacao,
        tipoParticipante: tipoParticipante ?? this.tipoParticipante,
      );
}
