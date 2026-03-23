import 'package:eventoweb_secretaria_front/data/models/pedidos/enum_tipo_pedido.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/inscricao_form_dialog.dart';
import 'package:eventoweb_secretaria_front/ui/pedidos/cadastro/view_model/pedido_cadastro_viewmodel.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PedidoCadastroScreen extends StatefulWidget {
  final PedidoCadastroViewModel viewModel;

  const PedidoCadastroScreen({required this.viewModel, super.key});

  @override
  State<PedidoCadastroScreen> createState() => _PedidoCadastroScreenState();
}

class _PedidoCadastroScreenState extends State<PedidoCadastroScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.carregarFormasPagamento.execute();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SEÇÃO: Inscrições no Pedido
                _buildInscricoesSection(context, currencyFormat),
                const SizedBox(height: 24),

                // SEÇÃO: Dados do Pagador
                _buildDadosPagadorSection(context),
                const SizedBox(height: 24),

                // SEÇÃO: Tipo de Pedido
                _buildTipoPedidoSection(context),
                const SizedBox(height: 24),

                // SEÇÃO: Controles Condicionais
                _buildControlesCondicionaisSection(context),
                const SizedBox(height: 24),

                // BOTÃO: Incluir Pedido
                _buildBotaoIncluirPedido(context),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInscricoesSection(BuildContext context, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inscrições no Pedido',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => InscricaoFormDialog(
                    idEvento: widget.viewModel.eventViewModel.eventoEscolhido!.id!,
                    idadeMinimaAdulto: widget.viewModel.eventViewModel.eventoEscolhido!.idadeMinimaAdulto,
                    inscricoesWS: widget.viewModel.inscricoesWS,
                    onSave: (inscricao) async {
                      
                      Result? result;
                      if (inscricao.id == null) {
                        await widget.viewModel.incluirInscricao.execute(inscricao);
                        result = widget.viewModel.incluirInscricao.result;
                      }
                      else {
                        await widget.viewModel.atualizarInscricao.execute(inscricao);
                        result = widget.viewModel.atualizarInscricao.result;
                      }
                      
                      if (context.mounted) {
                        if (result is OkCommand) {
                          Navigator.pop(context);
                        } else if (result is ErrorCommand) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao incluir: ${result.error}'))
                          );
                        }
                      }
                    },
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Nova Inscrição'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const Divider(),
        if (widget.viewModel.inscricoesNoPedido.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: Text('Nenhuma inscrição adicionada.')),
          )
        else
          Column(
            children: [
              ...widget.viewModel.inscricoesNoPedido.asMap().entries.map((entry) {
                final index = entry.key;
                final inscricao = entry.value;
                final valor = widget.viewModel.obterValorInscricao(inscricao);
                final valorDisplay = widget.viewModel.tipoPedidoSelecionado == EnumTipoPedido.debito
                    ? currencyFormat.format(valor)
                    : '--';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inscricao.pessoa.nome,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              inscricao.tipo.name,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        valorDisplay,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            widget.viewModel.inscricoesNoPedido.removeAt(index);
                            widget.viewModel.precosInscricoes.remove(inscricao.id);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.viewModel.tipoPedidoSelecionado == EnumTipoPedido.debito
                        ? currencyFormat.format(widget.viewModel.valorTotal)
                        : '--',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDadosPagadorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados do Pagador',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.viewModel.nomePagadorController,
          decoration: const InputDecoration(
            labelText: 'Nome do Pagador *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.viewModel.cpfPagadorController,
          decoration: const InputDecoration(
            labelText: 'CPF *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.viewModel.celularPagadorController,
          decoration: const InputDecoration(
            labelText: 'Celular *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.viewModel.emailPagadorController,
          decoration: const InputDecoration(
            labelText: 'E-mail *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildTipoPedidoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Pedido',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButton<EnumTipoPedido>(
          value: widget.viewModel.tipoPedidoSelecionado,
          isExpanded: true,
          hint: const Text('Selecione o tipo de pedido *'),
          onChanged: (EnumTipoPedido? value) {
            setState(() {
              widget.viewModel.tipoPedidoSelecionado = value;
              if (value == EnumTipoPedido.debito) {
                widget.viewModel.formaSelecionada = widget.viewModel.formasPagamento.isNotEmpty
                    ? widget.viewModel.formasPagamento.first
                    : null;
              } else {
                widget.viewModel.numeroParcelasController.clear();
              }
            });
          },
          items: EnumTipoPedido.values.map((tipo) {
            String label;
            switch (tipo) {
              case EnumTipoPedido.debito:
                label = 'Pagamento';
                break;
              case EnumTipoPedido.desconto:
                label = 'Desconto';
                break;
              case EnumTipoPedido.isencao:
                label = 'Isenção';
                break;
            }
            return DropdownMenuItem<EnumTipoPedido>(
              value: tipo,
              child: Text(label),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildControlesCondicionaisSection(BuildContext context) {
    if (widget.viewModel.tipoPedidoSelecionado == null) {
      return const SizedBox.shrink();
    }

    if (widget.viewModel.tipoPedidoSelecionado == EnumTipoPedido.debito) {
      return _buildControlesDebito(context);
    } else {
      return _buildControlesDescontoIsencao(context);
    }
  }

  Widget _buildControlesDebito(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forma de Pagamento',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButton<int?>(
          value: widget.viewModel.formaSelecionada?.id,
          isExpanded: true,
          hint: const Text('Selecione a forma de pagamento *'),
          onChanged: (int? formaId) {
            if (formaId != null) {
              final forma = widget.viewModel.formasPagamento
                  .firstWhere((f) => f.id == formaId);
              widget.viewModel.selecionarFormaPagamento.execute(forma);
              setState(() {
                widget.viewModel.formaSelecionada = forma;
              });
            }
          },
          items: widget.viewModel.formasPagamento.map((forma) {
            return DropdownMenuItem<int?>(
              value: forma.id,
              child: Text(forma.nome),
            );
          }).toList(),
        ),
        // Campo de Parcelas (se aplicável)
        if ((widget.viewModel.formaSelecionada?.nrParcelasMinima ?? 0) > 1) ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.viewModel.numeroParcelasController,
            decoration: InputDecoration(
              labelText:
                  'Número de Parcelas (${widget.viewModel.formaSelecionada?.nrParcelasMinima} - ${widget.viewModel.formaSelecionada?.nrParcelasMaxima}) *',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }

  Widget _buildControlesDescontoIsencao(BuildContext context) {
    final tipoLabel = widget.viewModel.tipoPedidoSelecionado == EnumTipoPedido.desconto
        ? 'Desconto'
        : 'Isenção';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.viewModel.motivoController,
          decoration: InputDecoration(
            labelText: 'Motivo da $tipoLabel *',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildBotaoIncluirPedido(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.viewModel.inscricoesNoPedido.isEmpty
          ? null
          : () async {
              await widget.viewModel.validarEIncluirPedido.execute();
              final result = widget.viewModel.validarEIncluirPedido.result;

              if (context.mounted) {
                if (result is OkCommand) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pedido incluído com sucesso!')),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) {
                      context.pop();
                    }
                  });
                } else if (result is ErrorCommand) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: ${result.error}')),
                  );
                }
              }
            },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
      ),
      child: const Text('INCLUIR PEDIDO'),
    );
  }
}
