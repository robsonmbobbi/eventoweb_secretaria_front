import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/ui/core/ui/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../utils/result.dart';
import '../../../core/themes/theme_back_button.dart';
import '../../../core/ui/message_panel_widget.dart';
import '../view_model/inscricoes_listagem_viewmodel.dart';
import 'inscricoes_listagem_data_source.dart';

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
    final buttonBackStyle = Theme.of(context).extension<ThemeBackButton>();

    return ListenableBuilder(
      listenable: Listenable.merge([widget.viewModel, widget.viewModel.escolherSituacao]),
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
          isLoading: widget.viewModel.escolherSituacao.running,
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
                    RadioGroup<EnumSituacaoInscricao>(
                      groupValue: widget.viewModel.situacaoEscolhida,
                      onChanged: (EnumSituacaoInscricao? newValue) {
                        if (newValue != null) {
                          widget.viewModel.escolherSituacao.execute(newValue);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRadioOption(EnumSituacaoInscricao.limbo, 'Limbo'),
                          _buildRadioOption(EnumSituacaoInscricao.pendente, 'Pendente'),
                          _buildRadioOption(EnumSituacaoInscricao.aceita, 'Aceita'),
                          _buildRadioOption(EnumSituacaoInscricao.rejeitada, 'Rejeitadas'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SfDataGrid(
                  source: InscricoesListagemDataSource(widget.viewModel.inscricoes, context),
                  allowFiltering: true,
                  allowSorting: true,
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
                      width: 140,
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text("Dormirá?"),
                      ),
                    ),
                    GridColumn(
                      columnName: "acoes",
                      width: 80,
                      allowFiltering: false,
                      allowSorting: false,
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text("Ações"),
                      ),
                    ),
                  ],
                  tableSummaryRows: [
                    GridTableSummaryRow(
                      showSummaryInRow: true,
                      title: 'Total de Registros: {totalCount}',
                      columns: [
                        GridSummaryColumn(
                          name: 'totalCount',
                          columnName: 'id',
                          summaryType: GridSummaryType.count,
                        ),
                      ],
                      position: GridTableSummaryRowPosition.bottom,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
