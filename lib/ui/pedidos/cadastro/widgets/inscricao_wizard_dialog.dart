import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_pesquisa_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:eventoweb_secretaria_front/ui/pedidos/cadastro/view_model/pedido_cadastro_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InscricaoWizardDialog extends StatefulWidget {
  final PedidoCadastroViewModel viewModel;

  const InscricaoWizardDialog({required this.viewModel, super.key});

  @override
  State<InscricaoWizardDialog> createState() => _InscricaoWizardDialogState();
}

class _InscricaoWizardDialogState extends State<InscricaoWizardDialog> {
  int _currentStep = 0;
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  DateTime? _dataNascimento;
  
  // Dados do formulário completo
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Inscrição'),
      content: SizedBox(
        width: 500,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _prevStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 2 ? 'SALVAR' : 'PRÓXIMO'),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('VOLTAR'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Identificação'),
              isActive: _currentStep >= 0,
              content: TextField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'Informe o CPF'),
                keyboardType: TextInputType.number,
              ),
            ),
            Step(
              title: const Text('Nascimento'),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  TextField(
                    controller: _cpfController,
                    decoration: const InputDecoration(labelText: 'CPF (Somente leitura)'),
                    enabled: false,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dataNascimentoController,
                    decoration: const InputDecoration(labelText: 'Data de Nascimento'),
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Formulário'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                   Text(
                    _isInfantil() ? 'INSCRIÇÃO INFANTIL' : 'INSCRIÇÃO ADULTO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isInfantil() ? Colors.blue : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome Completo'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  TextField(
                    controller: _celularController,
                    decoration: const InputDecoration(labelText: 'Celular'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isInfantil() {
    if (_dataNascimento == null) return false;
    return widget.viewModel.isInfantil(_dataNascimento!);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dataNascimento = picked;
        _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _nextStep() async {
    if (_currentStep == 0) {
      if (_cpfController.text.isEmpty) return;
      
      await widget.viewModel.pesquisarCPF.execute(_cpfController.text);
      final resultado = widget.viewModel.pesquisaAtual;

      if (resultado?.situacao == EnumSituacaoPesquisaPessoa.inscricaoRealizada) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Pessoa já possui inscrição realizada para este evento.'))
           );
         }
         return;
      }

      if (resultado?.pessoa != null) {
        _nomeController.text = resultado!.pessoa!.nome;
        _emailController.text = resultado.pessoa!.email;
        _celularController.text = resultado.pessoa!.celular;
        if (resultado.pessoa!.dataNascimento != null) {
          _dataNascimento = resultado.pessoa!.dataNascimento;
          _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(_dataNascimento!);
        }
      }
      
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      if (_dataNascimento == null) return;
      setState(() => _currentStep++);
    } else {
      _save();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _save() {
    final novaInscricao = DTOInscricao(
      idEvento: widget.viewModel.eventViewModel.eventoEscolhido!.id!,
      tipo: _isInfantil() ? EnumTipoInscricao.infantil : EnumTipoInscricao.adulto,
      pessoa: DTOPessoa(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        dataNascimento: _dataNascimento,
        email: _emailController.text,
        celular: _celularController.text,
      ),
    );

    widget.viewModel.adicionarInscricao(novaInscricao);
    Navigator.of(context).pop();
  }
}
