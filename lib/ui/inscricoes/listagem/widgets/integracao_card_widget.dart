import 'package:eventoweb_secretaria_front/data/models/registros_integracao/dto_registro_integracao.dart';
import 'package:eventoweb_secretaria_front/data/models/registros_integracao/enum_situacao_integracao.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/consulta_registro_integracao_dialog.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/integracao_logs_dialog.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/view_model/inscricoes_listagem_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IntegracaoCardWidget extends StatelessWidget {
  final DTORegistroIntegracao registro;
  final InscricoesListagemViewModel viewModel;

  const IntegracaoCardWidget({
    required this.registro,
    required this.viewModel,
    super.key,
  });

  Color _getStatusColor() {
    switch (registro.situacao) {
      case EnumSituacaoIntegracao.concluido:
        return Colors.green;
      case EnumSituacaoIntegracao.pendente:
        return Colors.orange;
      case EnumSituacaoIntegracao.erro:
      case EnumSituacaoIntegracao.abortado:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(),
          radius: 12,
        ),
        title: Text('${registro.tipo.name.toUpperCase()} - ${currencyFormat.format(registro.valor)}'),
        subtitle: Text(
          'Data: ${DateFormat('dd/MM/yyyy').format(registro.dataRegistro)}${registro.numeroParcelas != null ? ' - ${registro.numeroParcelas}x' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Consultar Integração',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ConsultaRegistroIntegracaoDialog(
                    viewModel: viewModel,
                    idRegistro: registro.id,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Visualizar Logs',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => IntegracaoLogsDialog(logs: registro.logs),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
