import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao_listagem.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InscricoesListagemDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> _dataGridRows = [];

  InscricoesListagemDataSource(List<DTOInscricaoListagem> inscricoes, this.context) {
    _dataGridRows = inscricoes
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'nome', value: e.nome),
              DataGridCell<String>(columnName: 'cidade', value: '${e.cidade ?? ""}/${e.uf ?? ""}'),
              DataGridCell<String>(columnName: 'tipo', value: e.tipo == EnumTipoInscricao.adulto ? 'Adulto' : 'Infantil'),
              DataGridCell<String>(columnName: 'dormira', value: e.dormira ? 'Sim' : 'Não'),
              DataGridCell<DTOInscricaoListagem>(columnName: 'acoes', value: e),
            ],
          ),
        )
        .toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        if (e.columnName == 'acoes') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navegar para tela de cadastro com detalhes do pedido
              },
            ),
          );
        }

        return Container(
          alignment: (e.columnName == 'id') ? Alignment.centerRight : (e.columnName == 'dormira' ? Alignment.center : Alignment.centerLeft),
          padding: const EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      alignment: Alignment.centerLeft,
      child: Text(
        summaryValue,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
