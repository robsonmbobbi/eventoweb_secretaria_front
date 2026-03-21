import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_forma_pagamento.dart';
import 'package:eventoweb_secretaria_front/data/models/registros_integracao/dto_registro_integracao_inclusao.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/view_model/inscricoes_listagem_viewmodel.dart';
import 'package:flutter/material.dart';

class NovoRegistroIntegracaoDialog extends StatefulWidget {
  final InscricoesListagemViewModel viewModel;

  const NovoRegistroIntegracaoDialog({required this.viewModel, super.key});

  @override
  State<NovoRegistroIntegracaoDialog> createState() => _NovoRegistroIntegracaoDialogState();
}

class _NovoRegistroIntegracaoDialogState extends State<NovoRegistroIntegracaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  DTOFormaPagamento? _formaSelecionada;
  int? _numeroParcelas;

  @override
  void initState() {
    super.initState();
    final pedido = widget.viewModel.pedidoDaInscricaoSelecionada;
    if (pedido != null && pedido.valor > 0) {
      _valorController.text = pedido.valor.toStringAsFixed(2);
    }
    
    _carregarFormas();
  }

  void _carregarFormas() async {
    await widget.viewModel.carregarFormasPagamento.execute();
    if (widget.viewModel.formasPagamento.isNotEmpty) {
      setState(() {
        _formaSelecionada = widget.viewModel.formasPagamento.first;
        _numeroParcelas = _formaSelecionada?.nrParcelasMinima;
      });
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Registro de Integração'),
      content: Form(
        key: _formKey,
        child: ListenableBuilder(
          listenable: widget.viewModel.carregarFormasPagamento,
          builder: (context, _) {
            if (widget.viewModel.carregarFormasPagamento.running) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe o valor';
                    final v = double.tryParse(value);
                    if (v == null || v <= 0) return 'Valor deve ser maior que zero';
                    return null;
                  },
                ),
                DropdownButtonFormField<DTOFormaPagamento>(
                  value: _formaSelecionada,
                  decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
                  items: widget.viewModel.formasPagamento.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f.nome),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _formaSelecionada = val;
                      _numeroParcelas = val?.nrParcelasMinima;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione a forma' : null,
                ),
                if (_formaSelecionada != null && _formaSelecionada!.nrParcelasMaxima > 1)
                  TextFormField(
                    initialValue: _numeroParcelas?.toString(),
                    decoration: InputDecoration(
                      labelText: 'Número de Parcelas',
                      helperText: 'Intervalo: ${_formaSelecionada!.nrParcelasMinima} a ${_formaSelecionada!.nrParcelasMaxima}',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _numeroParcelas = int.tryParse(val),
                    validator: (value) {
                      final p = int.tryParse(value ?? '');
                      if (p == null) return 'Informe as parcelas';
                      if (p < _formaSelecionada!.nrParcelasMinima || p > _formaSelecionada!.nrParcelasMaxima) {
                        return 'Fora do intervalo permitido';
                      }
                      return null;
                    },
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _confirmar() async {
    if (_formKey.currentState!.validate()) {
      final pedido = widget.viewModel.pedidoDaInscricaoSelecionada!;
      final dto = DTORegistroIntegracaoInclusao(
        idConta: pedido.conta.id,
        idFormaPagamento: _formaSelecionada!.id,
        idEvento: widget.viewModel.eventViewModel.eventoEscolhido!.id!,
        valor: double.parse(_valorController.text),
        numeroParcelas: _numeroParcelas,
      );

      await widget.viewModel.incluirRegistroIntegracao.execute(dto);
      if (mounted) {
        if (widget.viewModel.incluirRegistroIntegracao.error) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Erro ao salvar: ${widget.viewModel.incluirRegistroIntegracao.result}'))
           );
        } else {
          Navigator.pop(context);
        }
      }
    }
  }
}
