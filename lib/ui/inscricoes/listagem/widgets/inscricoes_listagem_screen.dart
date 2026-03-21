import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_listagem.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/ui/core/ui/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../utils/result.dart';
import '../../../core/themes/theme_back_button.dart';
import '../../../core/ui/message_panel_widget.dart';
import '../view_model/inscricoes_listagem_viewmodel.dart';
import 'inscricoes_listagem_data_source.dart';
import 'inscricao_detalhes_widget.dart';

class InscricoesListagemScreen extends StatefulWidget {
  final InscricoesListagemViewModel viewModel;

  const InscricoesListagemScreen({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => _InscricoesListagemScreenState();
}

class _InscricoesListagemScreenState extends State<InscricoesListagemScreen> {
  late MultiSplitViewController _controller;

  @override
  void initState() {
    _controller = MultiSplitViewController(
      areas: [
        Area(size: 400, min: 200),
        Area(min: 300),
      ],
    );
    Future.microtask(() {
      widget.viewModel.escolherSituacao.execute(EnumSituacaoInscricao.pendente);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final buttonBackStyle = Theme.of(context).extension<ThemeBackButton>();

    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel, 
        widget.viewModel.escolherSituacao,
        widget.viewModel.selecionarInscricao
      ]),
      builder: (context, child) {
        if (widget.viewModel.escolherSituacao.error) {
          var errorCmd = widget.viewModel.escolherSituacao.result as ErrorCommand;
          widget.viewModel.escolherSituacao.clearResult();

          return MessagePanelWidget(
            message: 'Ocorreu um problema!!!\n${errorCmd.error}',
            type: MessagePanelType.error,
          );
        }

        return LoadingOverlay(
          isLoading: widget.viewModel.escolherSituacao.running || widget.viewModel.selecionarInscricao.running,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: buttonBackStyle?.theme,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.arrow_back), SizedBox(width: 4), Text('Voltar')],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.viewModel.eventViewModel.eventoEscolhido?.nome ?? ""} - Inscrições',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                         context.push('/evento/${widget.viewModel.eventViewModel.eventoEscolhido!.id}/pedidos/novo');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Inscrição'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildSituacaoRadios(),
                  ],
                ),
              ),
              Expanded(
                child: MultiSplitViewTheme(
                  data: MultiSplitViewThemeData(
                    dividerPainter: DividerPainters.background(
                      color: Colors.grey[300]!,
                      highlightedColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: MultiSplitView(
                    controller: _controller,
                    pushDividers: true,
                    builder: (context, area) {
                      if (area.index == 0) {
                        return _buildGrid();
                      } else {
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4,
                          child: InscricaoDetalhesWidget(viewModel: widget.viewModel),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return SfDataGrid(
      source: InscricoesListagemDataSource(widget.viewModel.inscricoes, context),
      allowFiltering: true,
      allowSorting: true,
      selectionMode: SelectionMode.single,
      navigationMode: GridNavigationMode.row,
      onSelectionChanged: (addedRows, removedRows) {
        if (addedRows.isNotEmpty) {
          final row = addedRows.first;
          final DTOInscricaoListagem inscricao = row.getCells()
              .firstWhere((c) => c.columnName == 'acoes')
              .value;
          widget.viewModel.selecionarInscricao.execute(inscricao);
        }
      },
      columns: [
        GridColumn(
          columnName: "id",
          width: 80,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: const Text("Id"),
          ),
        ),
        GridColumn(
          columnName: "nome",
          columnWidthMode: ColumnWidthMode.fill,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text("Nome"),
          ),
        ),
        GridColumn(
          columnName: "cidade",
          columnWidthMode: ColumnWidthMode.fill,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text("Cidade/UF"),
          ),
        ),
        GridColumn(
          columnName: "tipo",
          width: 120,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: const Text("Tipo"),
          ),
        ),
        GridColumn(
          columnName: "dormira",
          width: 100,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text("Dormirá?"),
          ),
        ),
        GridColumn(
          columnName: "acoes",
          width: 60,
          visible: false,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text("Ações"),
          ),
        ),
      ],
    );
  }

  Widget _buildSituacaoRadios() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRadioOption(EnumSituacaoInscricao.limbo, 'Limbo'),
        _buildRadioOption(EnumSituacaoInscricao.pendente, 'Pendente'),
        _buildRadioOption(EnumSituacaoInscricao.aceita, 'Aceita'),
        _buildRadioOption(EnumSituacaoInscricao.rejeitada, 'Rejeitadas'),
      ],
    );
  }

  Widget _buildRadioOption(EnumSituacaoInscricao value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<EnumSituacaoInscricao>(
          value: value,
        ),
        Text(label),
        const SizedBox(width: 8),
      ],
    );
  }
}
