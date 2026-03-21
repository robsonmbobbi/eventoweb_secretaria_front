import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_participante.dart';
import 'package:eventoweb_secretaria_front/data/models/pedidos/enum_tipo_pedido.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/view_model/inscricoes_listagem_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/integracao_card_widget.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/novo_registro_integracao_dialog.dart';
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
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar Inscrição',
                onPressed: () {
                   // AÇÃO: Abrir janela de alteração dos dados 
                },
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

          const SizedBox(height: 24),
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
            ...integracoes.map((reg) => IntegracaoCardWidget(registro: reg)).toList(),
          
          const SizedBox(height: 16),
          if (pedido != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLiquidarConta(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Liquidar Conta Diretamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
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

  void _showLiquidarConta(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liquidar Conta'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Informe os valores para liquidação direta da conta vinculada.'),
            TextField(decoration: InputDecoration(labelText: 'Valor Desconto'), keyboardType: TextInputType.number),
            TextField(decoration: InputDecoration(labelText: 'Valor Acréscimo'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Liquidar')),
        ],
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
