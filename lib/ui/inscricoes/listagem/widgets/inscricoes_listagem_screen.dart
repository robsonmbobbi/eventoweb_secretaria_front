import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/ui/core/ui/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../utils/result.dart';
import '../../../core/ui/message_panel_widget.dart';
import '../view_model/inscricoes_listagem_viewmodel.dart';
import 'InscricoesListagemDataSource.dart';

class InscricoesListagemScreen extends StatefulWidget {

  final InscricoesListagemViewModel viewModel;

  const InscricoesListagemScreen({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => _InscricoesListagemScreenState();
}

class _InscricoesListagemScreenState extends State<InscricoesListagemScreen> {

  @override
  void initState() {

    Future.microtask(() {
      widget.viewModel.escolherSituacao.execute(EnumSituacaoInscricao.pendente);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Inscrições"),
            const SizedBox(width: 20),
            RadioGroup<EnumSituacaoInscricao>(
              groupValue: widget.viewModel.situacaoEscolhida,
              onChanged: (EnumSituacaoInscricao? value) {
                widget.viewModel.escolherSituacao.execute(value ?? EnumSituacaoInscricao.limbo);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: [
                      Radio<EnumSituacaoInscricao>(value: EnumSituacaoInscricao.limbo),
                      Text('Limbo')
                    ],
                  ),
                  const Row(
                    children: [
                      Radio<EnumSituacaoInscricao>(value: EnumSituacaoInscricao.pendente),
                      Text('Pendentes')
                    ],
                  ),
                  const Row(
                    children: [
                      Radio<EnumSituacaoInscricao>(value: EnumSituacaoInscricao.aceita),
                      Text('Aceitas')
                    ],
                  ),
                  const Row(
                    children: [
                      Radio<EnumSituacaoInscricao>(value: EnumSituacaoInscricao.rejeitada),
                      Text('Rejeitadas')
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([widget.viewModel, widget.viewModel.escolherSituacao]),
            builder: (ctx, child) {
              if (widget.viewModel.escolherSituacao.error) {
                var errorCmd = widget.viewModel.escolherSituacao.result as ErrorCommand;
                widget.viewModel.escolherSituacao.clearResult();

                return MessagePanelWidget(
                    message: 'Ocorreu um problema!!\n${errorCmd.error}',
                    type: MessagePanelType.error
                );
              }

              return LoadingOverlay(
                isLoading: widget.viewModel.escolherSituacao.running,
                child: Text("dsds")
              );
            }
          )
        )
      ],
    );
  }
}