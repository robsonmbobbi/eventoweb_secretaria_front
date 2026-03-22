import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/ui/core/themes/theme_back_button.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/inscricao_form_dialog.dart';
import 'package:eventoweb_secretaria_front/ui/pedidos/cadastro/view_model/pedido_cadastro_viewmodel.dart';
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
    final buttonBackStyle = Theme.of(context).extension<ThemeBackButton>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido / Inscrição'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              final result = await widget.viewModel.incluirInscricao.execute(inscricao);
                              if (context.mounted) {
                                if (result.isOk) {
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao incluir: ${result.asError.error}'))
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Nova Inscrição'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: widget.viewModel.inscricoesNoPedido.isEmpty
                      ? const Center(child: Text('Nenhuma inscrição adicionada.'))
                      : ListView.builder(
                          itemCount: widget.viewModel.inscricoesNoPedido.length,
                          itemBuilder: (context, index) {
                            final inscricao = widget.viewModel.inscricoesNoPedido[index];
                            return ListTile(
                              title: Text(inscricao.pessoa.nome),
                              subtitle: Text(inscricao.tipo.name),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    widget.viewModel.inscricoesNoPedido.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total do Pedido:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              currencyFormat.format(widget.viewModel.inscricoesNoPedido.length * 100.0), // TODO: Usar cálculo real por preço
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: widget.viewModel.inscricoesNoPedido.isEmpty 
                              ? null 
                              : () {
                                 // TODO: Ir para Pagamento
                              },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('REALIZAR PAGAMENTO'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
