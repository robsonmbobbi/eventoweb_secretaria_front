import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_responsavel.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_sexo.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_pesquisa_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_participante.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  DateTime? _dataNascimento;
  
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _instituicaoController = TextEditingController();
  final _nomeCrachaController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _resp1CpfController = TextEditingController();
  final _resp1NomeController = TextEditingController();

  bool _dormeEvento = true;
  bool _ehVegetariano = false;
  bool _ehDiabetico = false;
  bool _usaAdocante = false;
  EnumSexo? _sexo;
  EnumTipoParticipante? _tipoParticipante;

  @override
  void dispose() {
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _instituicaoController.dispose();
    _nomeCrachaController.dispose();
    _observacoesController.dispose();
    _alergiasController.dispose();
    _resp1CpfController.dispose();
    _resp1NomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Inscrição'),
      content: SizedBox(
        width: 800,
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
                decoration: const InputDecoration(labelText: 'Informe o CPF*'),
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
                    decoration: const InputDecoration(labelText: 'Data de Nascimento*'),
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Formulário Completo'),
              isActive: _currentStep >= 2,
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPessoaFields(),
                    const Divider(),
                    _buildInscricaoFields(),
                    if (_isInfantil()) ...[
                      const Divider(),
                      _buildResponsavelFields(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPessoaFields() {
    return Column(
      children: [
        Text(
          _isInfantil() ? 'INSCRIÇÃO INFANTIL' : 'INSCRIÇÃO ADULTO',
          style: TextStyle(fontWeight: FontWeight.bold, color: _isInfantil() ? Colors.blue : Colors.orange),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nomeController,
          decoration: const InputDecoration(labelText: 'Nome Completo*'),
          validator: (v) => v == null || v.isEmpty ? 'Nome é obrigatório' : null,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail*'),
                validator: (v) => v == null || v.isEmpty ? 'E-mail é obrigatório' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _celularController,
                decoration: const InputDecoration(labelText: 'Celular*'),
                validator: (v) => v == null || v.isEmpty ? 'Celular é obrigatório' : null,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _ufController, decoration: const InputDecoration(labelText: 'UF'))),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<EnumSexo>(
                value: _sexo,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: EnumSexo.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => _sexo = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCheckbox('Veg.', _ehVegetariano, (v) => setState(() => _ehVegetariano = v!)),
            _buildCheckbox('Diab.', _ehDiabetico, (v) => setState(() => _ehDiabetico = v!)),
            _buildCheckbox('Adoc.', _usaAdocante, (v) => setState(() => _usaAdocante = v!)),
          ],
        ),
        TextFormField(controller: _alergiasController, decoration: const InputDecoration(labelText: 'Alergias Alimentares')),
      ],
    );
  }

  Widget _buildInscricaoFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nomeCrachaController,
                decoration: const InputDecoration(labelText: 'Nome Crachá*'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 16),
            _buildCheckbox('Dormirá?', _dormeEvento, (v) => setState(() => _dormeEvento = v!)),
          ],
        ),
        if (!_isInfantil()) ...[
          TextFormField(controller: _instituicaoController, decoration: const InputDecoration(labelText: 'Instituição')),
          DropdownButtonFormField<EnumTipoParticipante>(
            value: _tipoParticipante,
            decoration: const InputDecoration(labelText: 'Tipo Participante'),
            items: EnumTipoParticipante.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
            onChanged: (v) => setState(() => _tipoParticipante = v),
          ),
        ],
        TextFormField(controller: _observacoesController, decoration: const InputDecoration(labelText: 'Observações'), maxLines: 2),
      ],
    );
  }

  Widget _buildResponsavelFields() {
    return Column(
      children: [
        const Text('Responsável', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _resp1CpfController,
                decoration: const InputDecoration(labelText: 'CPF Resp.*'),
                validator: (v) => _isInfantil() && (v == null || v.isEmpty) ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _resp1NomeController,
                decoration: const InputDecoration(labelText: 'Nome Resp.*'),
                validator: (v) => _isInfantil() && (v == null || v.isEmpty) ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
        const SizedBox(width: 4),
      ],
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
      final res = widget.viewModel.pesquisaAtual;
      if (res?.situacao == EnumSituacaoPesquisaPessoa.inscricaoRealizada) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Já possui inscrição.')));
        return;
      }
      if (res?.pessoa != null) {
        _nomeController.text = res!.pessoa!.nome;
        _emailController.text = res.pessoa!.email;
        _celularController.text = res.pessoa!.celular;
        _cidadeController.text = res.pessoa!.cidade ?? '';
        _ufController.text = res.pessoa!.uf ?? '';
        _sexo = res.pessoa!.sexo;
        if (res.pessoa!.dataNascimento != null) {
          _dataNascimento = res.pessoa!.dataNascimento;
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
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final novaInscricao = DTOInscricao(
        idEvento: widget.viewModel.eventViewModel.eventoEscolhido!.id!,
        tipo: _isInfantil() ? EnumTipoInscricao.infantil : EnumTipoInscricao.adulto,
        pessoa: DTOPessoa(
          nome: _nomeController.text,
          cpf: _cpfController.text,
          dataNascimento: _dataNascimento,
          email: _emailController.text,
          celular: _celularController.text,
          cidade: _cidadeController.text,
          uf: _ufController.text,
          sexo: _sexo,
          ehVegetariano: _ehVegetariano,
          ehDiabetico: _ehDiabetico,
          usaAdocanteDiariamente: _usaAdocante,
          alergiaAlimentos: _alergiasController.text,
        ),
        nomeCracha: _nomeCrachaController.text,
        dormeEvento: _dormeEvento,
        instituicoesEspiritasFrequenta: !_isInfantil() ? _instituicaoController.text : null,
        tipoParticipante: _tipoParticipante,
        observacoes: _observacoesController.text,
        responsavel1: _isInfantil() ? DTOResponsavel(idInscricao: 0, cpf: _resp1CpfController.text, nome: _resp1NomeController.text) : null,
      );

      await widget.viewModel.incluirInscricao.execute(novaInscricao);
      if (mounted) {
        if (widget.viewModel.incluirInscricao.error) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${widget.viewModel.incluirInscricao.result}')));
        } else {
          Navigator.pop(context);
        }
      }
    }
  }
}
