import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InscricoesListagemDataSource extends DataGridSource {

  List<DataGridRow> _dataGridRows = [];

  InscricoesListagemDataSource(List<DTOInscricao> inscricoes) {
    _dataGridRows =
        inscricoes
            .map<DataGridRow>(
              (e) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'nome', value: e.pessoa.nome),
              DataGridCell<DTOPessoa>(columnName: 'cidade', value: e.pessoa),
              DataGridCell<EnumTipoInscricao>(columnName: 'tipo', value: e.tipo),
              DataGridCell<bool>(columnName: 'dormira', value: e.dormeEvento),
              //DataGridCell<bool>(columnName: 'presente', value: e.),
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
      cells:
      row.getCells().map<Widget>((e) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }

}