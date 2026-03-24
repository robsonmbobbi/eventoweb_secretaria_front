import 'dart:convert';
import 'package:eventoweb_secretaria_front/data/models/financeiro/enum_status_transacao.dart';
import 'package:eventoweb_secretaria_front/data/models/financeiro/enum_tipo_pagamento.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/view_model/inscricoes_listagem_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultaRegistroIntegracaoDialog extends StatefulWidget {
  final InscricoesListagemViewModel viewModel;
  final int idRegistro;

  const ConsultaRegistroIntegracaoDialog({
    required this.viewModel,
    required this.idRegistro,
    super.key,
  });

  @override
  State<ConsultaRegistroIntegracaoDialog> createState() =>
      _ConsultaRegistroIntegracaoDialogState();
}

class _ConsultaRegistroIntegracaoDialogState
    extends State<ConsultaRegistroIntegracaoDialog> {
  late final Future<void> _consultarFuture;

  @override
  void initState() {
    super.initState();
    _consultarFuture = widget.viewModel.consultarRegistroIntegracao
        .execute(widget.idRegistro)
        .then((_) {});
  }

  String _getStatusIcon() {
    final data = widget.viewModel.consultaRegistroSelecionada;
    if (data == null) return '';

    switch (data.status) {
      case EnumStatusTransacao.recebida:
        return '✅';
      case EnumStatusTransacao.pendente:
        return '⏳';
      case EnumStatusTransacao.cancelada:
        return '❌';
    }
  }

  String _getStatusText() {
    final data = widget.viewModel.consultaRegistroSelecionada;
    if (data == null) return '';

    switch (data.status) {
      case EnumStatusTransacao.recebida:
        return 'RECEBIDA';
      case EnumStatusTransacao.pendente:
        return 'PENDENTE';
      case EnumStatusTransacao.cancelada:
        return 'CANCELADA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final statusIcon = _getStatusIcon();
    final statusText = _getStatusText();

    return AlertDialog(
      title: const Text('Consulta de Registro de Integração'),
      content: FutureBuilder<void>(
        future: _consultarFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Erro ao consultar registro',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            );
          }

          final consultaData =
              widget.viewModel.consultaRegistroSelecionada;

          if (consultaData == null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                Text('Nenhum dado encontrado',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status
                Row(
                  children: [
                    Text(statusIcon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text('Status: $statusText',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Valor: ${currencyFormat.format(consultaData.valor)}',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // PIX
                if (consultaData.tipoTransacao == EnumTipoPagamento.pix) ...[
                  Text('Dados do PIX',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  // QR Code
                  if (consultaData.imagemQRCodePixBase64 != null &&
                      consultaData.imagemQRCodePixBase64!.isNotEmpty) ...[
                    Text('QR Code:',
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.memory(
                        base64Decode(consultaData.imagemQRCodePixBase64!),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pix Copia e Cola
                  if (consultaData.pixCopiaECola != null &&
                      consultaData.pixCopiaECola!.isNotEmpty) ...[
                    Text('Pix Copia e Cola:',
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    _buildCopiableTextField(
                      value: consultaData.pixCopiaECola!,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                // Cartão - Link
                if (consultaData.tipoTransacao == EnumTipoPagamento.cartaoCredito) ...[
                  Text('Dados do Pagamento',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (consultaData.linkPagamento != null &&
                      consultaData.linkPagamento!.isNotEmpty) ...[
                    Text('Link de Pagamento:',
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    _buildCopiableTextField(
                      value: consultaData.linkPagamento!,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildCopiableTextField({
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copiar',
          onPressed: () {
            _copyToClipboard(value, context);
          },
        ),
      ],
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiado para a área de transferência!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
