import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_participante.dart';
import 'package:eventoweb_secretaria_front/data/models/pedidos/enum_tipo_pedido.dart';
import 'package:eventoweb_secretaria_front/data/models/financeiro/dto_liquidacao_conta.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/view_model/inscricoes_listagem_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/inscricao_form_dialog.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/integracao_card_widget.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/novo_registro_integracao_dialog.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InscricaoDetalhesWidget extends StatelessWidget {
  final InscricoesListagemViewModel viewModel;

  const InscricaoDetalhesWidget({required this.viewModel, super.key});

  String _formatCPF(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.inscricaoSelecionada == null) {
      return const Center(
        child: Text('Selecione uma inscrição para ver os detalhes.'),
      );
    }

    final inscricao = viewModel.inscricaoCompletaSelecionada;
    final pedido = viewModel.pedidoDaInscricaoSelecionada;
    final integracoes = viewModel.registrosIntegracao;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (inscricao == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detalhes da Inscrição',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  if (inscricao.situacao == EnumSituacaoInscricao.pendente)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      tooltip: 'Aceitar Inscrição',
                      color: Colors.green,
                      onPressed: () => _aceitarInscricao(context),
                    ),
                  if (inscricao.situacao == EnumSituacaoInscricao.pendente)
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      tooltip: 'Rejeitar Inscrição',
                      color: Colors.orange,
                      onPressed: () => _rejeitarInscricao(context),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Editar Inscrição',
                    onPressed: () {
                       showDialog(
                         context: context,
                         barrierDismissible: false,
                         builder: (context) => InscricaoFormDialog(
                           idEvento: viewModel.eventViewModel.eventoEscolhido!.id!,
                           idadeMinimaAdulto: viewModel.eventViewModel.eventoEscolhido!.idadeMinimaAdulto,
                           inscricoesWS: viewModel.inscricoesWS,
                           inscricao: inscricao,
                           onSave: (inscricaoAtualizada) async {
                             await viewModel.atualizarInscricao.execute(inscricaoAtualizada);
                             final res = viewModel.atualizarInscricao.result;
                             if (context.mounted) {
                               if (res is OkCommand) {
                                 Navigator.pop(context);
                               } else if (res is ErrorCommand) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text('Erro ao atualizar: ${res.error}'))
                                 );
                               }
                             }
                           },
                         ),
                       );
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          
          _buildSectionTitle(context, 'Dados Pessoais'),
          _buildInfoRow('Nome:', inscricao.pessoa.nome),
          _buildInfoRow('CPF:', _formatCPF(inscricao.pessoa.cpf)),
          _buildInfoRow('Data Nasc.:', inscricao.pessoa.dataNascimento != null ? dateFormat.format(inscricao.pessoa.dataNascimento!) : '-'),
          _buildInfoRow('E-mail:', inscricao.pessoa.email),
          _buildInfoRow('Celular:', _formatPhone(inscricao.pessoa.celular)),
          _buildInfoRow('Cidade/UF:', '${inscricao.pessoa.cidade ?? ""}/${inscricao.pessoa.uf ?? ""}'),
          _buildInfoRow('Sexo:', inscricao.pessoa.sexo?.name ?? '-'),

          _buildSectionTitle(context, 'Detalhes da Participação'),
          _buildInfoRow('Tipo Inscrição:', inscricao.tipo.name),
          if (inscricao.tipo == EnumTipoInscricao.adulto) ...[
            _buildInfoRow('Tipo Participante:', _getTipoDescricao(inscricao)),
            _buildInfoRow('Instituição:', inscricao.instituicoesEspiritasFrequenta ?? '-'),
          ],
          _buildInfoRow('Dormirá no Evento:', inscricao.dormeEvento ? 'Sim' : 'Não'),
          _buildInfoRow('Nome Crachá:', inscricao.nomeCracha ?? '-'),
          _buildInfoRow('Observações:', inscricao.observacoes ?? '-'),

          if (inscricao.responsavel1 != null) ...[
             _buildSectionTitle(context, 'Responsável 1'),
             _buildInfoRow('Nome:', inscricao.responsavel1!.nome ?? ""),
             _buildInfoRow('CPF:', _formatCPF(inscricao.responsavel1!.cpf ?? "")),
          ],
          if (inscricao.responsavel2 != null) ...[
             _buildSectionTitle(context, 'Responsável 2'),
             _buildInfoRow('Nome:', inscricao.responsavel2!.nome ?? ""),
             _buildInfoRow('CPF:', _formatCPF(inscricao.responsavel2!.cpf ?? "")),
          ],

          const SizedBox(height: 24),
          if (inscricao.situacao != EnumSituacaoInscricao.limbo) ...[
            Text(
              'Dados do Pedido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            if (pedido != null) ...[
            _buildInfoRow('ID Pedido: ', pedido.id.toString()),
            _buildInfoRow('Valor Pedido:', currencyFormat.format(pedido.valor)),
            _buildInfoRow('Tipo Pedido:', pedido.tipo.name.toUpperCase()),
            if (pedido.tipo == EnumTipoPedido.debito && pedido.formaPagamento != null)
              _buildInfoRow('Forma Pgto:', pedido.formaPagamento!.nome),
            _buildInfoRow('Pagador:', pedido.pagador.nome),
            _buildInfoRow('CPF Pagador:', _formatCPF(pedido.pagador.cpf)),
            _buildInfoRow('E-mail Pagador:', pedido.pagador.email),
            _buildInfoRow('Tel. Pagador:', _formatPhone(pedido.pagador.celular)),
            
            const SizedBox(height: 12),
            _buildInfoRow('Situação Conta:', pedido.conta.liquidado ? 'LIQUIDADA' : 'EM ABERTO'),
            _buildInfoRow('Valor Conta:', currencyFormat.format(pedido.conta.valor)),
            _buildInfoRow('Valor Pago:', currencyFormat.format(pedido.conta.valorTotalTransacoes)),
            
            _buildSectionTitle(context, 'Inscrições Vinculadas'),
            ...pedido.inscricoes.map((insV) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Card(
                child: ListTile(
                  dense: true,
                  title: Text(insV.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${insV.tipo.name} - ${insV.cidade ?? ""}/${insV.uf ?? ""}'),
                ),
              ),
            )),
            ] else
              const Text('Carregando dados do pedido...'),
          ],

          if (inscricao.situacao != EnumSituacaoInscricao.limbo) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registros de Integração',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Novo Registro de Integração',
                  onPressed: () {
                     showDialog(
                       context: context,
                       barrierDismissible: false,
                       builder: (context) => NovoRegistroIntegracaoDialog(viewModel: viewModel),
                     );
                  },
                ),
              ],
            ),
            const Divider(),
            if (integracoes.isEmpty)
              const Text('Nenhum registro de integração encontrado.')
            else
              ...integracoes.map((reg) => IntegracaoCardWidget(registro: reg, viewModel: viewModel)),
            
            const SizedBox(height: 16),
            if (pedido != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: pedido.conta.liquidado ? null : () => _showLiquidarConta(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Liquidar Conta Diretamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pedido.conta.liquidado ? Colors.grey : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _aceitarInscricao(BuildContext context) async {
    if (viewModel.inscricaoSelecionada?.id == null) return;
    
    await viewModel.aceitarInscricao.execute(
      viewModel.inscricaoSelecionada!.id!
    );
    
    final res = viewModel.aceitarInscricao.result;
    if (context.mounted) {
      if (res is OkCommand) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição aceita com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (res is ErrorCommand) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aceitar: ${res.error}'))
        );
      }
    }
  }

  Future<void> _rejeitarInscricao(BuildContext context) async {
    if (viewModel.inscricaoSelecionada?.id == null) return;
    
    await viewModel.rejeitarInscricao.execute(
      viewModel.inscricaoSelecionada!.id!
    );
    
    final res = viewModel.rejeitarInscricao.result;
    if (context.mounted) {
      if (res is OkCommand) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição rejeitada com sucesso!'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (res is ErrorCommand) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao rejeitar: ${res.error}'))
        );
      }
    }
  }

  void _showLiquidarConta(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LiquidarContaDialog(
        viewModel: viewModel,
        idConta: viewModel.pedidoDaInscricaoSelecionada?.conta.id ?? 0,
        onSuccess: () {
          // Atualizar dados após liquidação bem-sucedida
          if (viewModel.inscricaoSelecionada != null) {
            viewModel.selecionarInscricao.execute(viewModel.inscricaoSelecionada!);
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getTipoDescricao(dynamic inscricao) {
    if (inscricao.tipoParticipante == null) return 'Não informado';
    
    switch (inscricao.tipoParticipante) {
      case EnumTipoParticipante.participante: return 'Participante';
      case EnumTipoParticipante.participanteTrabalhador: return 'Participante/Trabalhador';
      case EnumTipoParticipante.trabalhador: return 'Trabalhador';
      default: return 'Adulto';
    }
  }
}

class _LiquidarContaDialog extends StatefulWidget {
  final InscricoesListagemViewModel viewModel;
  final int idConta;
  final VoidCallback onSuccess;

  const _LiquidarContaDialog({
    required this.viewModel,
    required this.idConta,
    required this.onSuccess,
  });

  @override
  State<_LiquidarContaDialog> createState() => _LiquidarContaDialogState();
}

class _LiquidarContaDialogState extends State<_LiquidarContaDialog> {
  final TextEditingController _valorPagoController = TextEditingController();
  int? _contaBancariaId;
  bool _isLoading = false;
  bool _isLoadingContas = true;
  List<dynamic> _contas = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContas();
  }

  Future<void> _loadContas() async {
    try {
      final contas = await widget.viewModel.contasBancariasWS.listar();
      setState(() {
        _contas = contas;
        _isLoadingContas = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar contas bancárias: $e';
        _isLoadingContas = false;
      });
    }
  }

  Future<void> _liquidarConta() async {
    // Validações
    final valorText = _valorPagoController.text.trim();
    if (valorText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o valor pago.')),
      );
      return;
    }

    if (_contaBancariaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma conta bancária.')),
      );
      return;
    }

    final valor = double.tryParse(valorText.replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dto = DTOLiquidacaoConta(
        idConta: widget.idConta,
        idContaBancaria: _contaBancariaId!,
        valor: valor,
      );

      await widget.viewModel.contasWS.liquidar(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta liquidada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao liquidar conta: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _valorPagoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Liquidar Conta'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informe o valor pago e a conta bancária para a liquidação.'),
              const SizedBox(height: 16),
              
              // Campo de Valor Pago
              TextField(
                controller: _valorPagoController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Valor Pago',
                  hintText: '0,00',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Dropdown de Conta Bancária
              if (_isLoadingContas)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                )
              else if (_errorMessage != null && _contas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  value: _contaBancariaId,
                  disabledHint: _isLoading ? const Text('Carregando...') : null,
                  decoration: const InputDecoration(
                    labelText: 'Conta Bancária',
                    border: OutlineInputBorder(),
                  ),
                  items: _contas.map((conta) {
                    return DropdownMenuItem<int>(
                      value: conta.id,
                      child: Text(conta.nomeConta),
                    );
                  }).toList(),
                  onChanged: _isLoading ? null : (value) {
                    setState(() {
                      _contaBancariaId = value;
                    });
                  },
                ),

              // Mensagem de erro
              if (_errorMessage != null && _isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _isLoadingContas ? null : _liquidarConta,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Liquidar'),
        ),
      ],
    );
  }
}
