import 'package:eventoweb_secretaria_front/data/models/registros_integracao/dto_registro_integracao_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IntegracaoLogsDialog extends StatelessWidget {
  final List<DTORegistroIntegracaoLog> logs;

  const IntegracaoLogsDialog({required this.logs, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logs de Integração'),
      content: SizedBox(
        width: 600,
        child: logs.isEmpty
            ? const Center(child: Text('Nenhum log encontrado.'))
            : ListView.separated(
                shrinkWrap: true,
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    title: Text(log.mensagem),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm:ss').format(log.data),
                    ),
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
