import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/dto_responsavel.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_sexo.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_situacao_pesquisa_pessoa.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_inscricao.dart';
import 'package:eventoweb_secretaria_front/data/models/inscricoes/enum_tipo_participante.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/inscricoes_ws.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Lista de estados brasileiros
const List<String> estadosBrasileiros = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
  'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
  'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
];

// Funções de validação e formatação
bool _isValidCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'\D'), '');
  if (cpf.length != 11) return false;
  if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
  
  int sum = 0;
  int remainder;
  for (int i = 1; i <= 9; i++) {
    sum += int.parse(cpf.substring(i - 1, i)) * (11 - i);
  }
  remainder = (sum * 10) % 11;
  if (remainder == 10 || remainder == 11) remainder = 0;
  if (remainder != int.parse(cpf.substring(9, 10))) return false;
  
  sum = 0;
  for (int i = 1; i <= 10; i++) {
    sum += int.parse(cpf.substring(i - 1, i)) * (12 - i);
  }
  remainder = (sum * 10) % 11;
  if (remainder == 10 || remainder == 11) remainder = 0;
  if (remainder != int.parse(cpf.substring(10, 11))) return false;
  
  return true;
}

bool _isValidEmail(String email) {
  return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
}

bool _isValidPhone(String phone) {
  phone = phone.replaceAll(RegExp(r'\D'), '');
  return phone.length == 11 || phone.length == 10;
}

class InscricaoFormDialog extends StatefulWidget {
  final DTOInscricao? inscricao; // Se nulo, é inclusão
  final int idEvento;
  final int idadeMinimaAdulto;
  final InscricoesWS inscricoesWS;
  final Function(DTOInscricao) onSave;

  const InscricaoFormDialog({
    this.inscricao,
    required this.idEvento,
    required this.idadeMinimaAdulto,
    required this.inscricoesWS,
    required this.onSave,
    super.key,
  });

  @override
  State<InscricaoFormDialog> createState() => _InscricaoFormDialogState();
}

class _InscricaoFormDialogState extends State<InscricaoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _instituicaoController = TextEditingController();
  final _nomeCrachaController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _alergiasController = TextEditingController();

  // Responsáveis
  final _resp1CpfController = TextEditingController();
  final _resp1NomeController = TextEditingController();
  final _resp2CpfController = TextEditingController();
  final _resp2NomeController = TextEditingController();

  bool _resp1Found = false;
  int? _idInscResp1 = null;
  bool _resp2Found = false;
  int? _idInscResp2 = null;

  DateTime? _dataNascimento;
  bool _dormeEvento = true;
  bool _ehVegetariano = false;
  bool _ehDiabetico = false;
  bool _usaAdocante = false;
  EnumSexo? _sexo;
  EnumTipoParticipante? _tipoParticipante;

  // Rastreia inscrição em limbo encontrada durante pesquisa (estado de inclusão)
  DTOInscricao? _inscricaoEmLimbo;

  bool get _isEdition => widget.inscricao != null;

  @override
  void initState() {
    super.initState();
    if (_isEdition) {
      _preencherCampos(widget.inscricao!);
    }
  }

  void _preencherCampos(DTOInscricao ins) {
    final p = ins.pessoa;
    _cpfController.text = p.cpf;
    _dataNascimento = p.dataNascimento;
    if (_dataNascimento != null) {
      _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(_dataNascimento!);
    }
    _nomeController.text = p.nome;
    _emailController.text = p.email;
    _celularController.text = p.celular;
    _cidadeController.text = p.cidade ?? '';
    _ufController.text = p.uf ?? '';
    _sexo = p.sexo;
    _ehVegetariano = p.ehVegetariano;
    _ehDiabetico = p.ehDiabetico;
    _usaAdocante = p.usaAdocanteDiariamente;
    _alergiasController.text = p.alergiaAlimentos ?? '';

    _nomeCrachaController.text = ins.nomeCracha ?? '';
    _dormeEvento = ins.dormeEvento;
    _instituicaoController.text = ins.instituicoesEspiritasFrequenta ?? '';
    _tipoParticipante = ins.tipoParticipante;
    _observacoesController.text = ins.observacoes ?? '';

    if (ins.responsavel1 != null) {
      _resp1CpfController.text = ins.responsavel1!.cpf ?? '';
      _resp1NomeController.text = ins.responsavel1!.nome ?? '';
      _idInscResp1 = ins.responsavel1!.idInscricao;
      _resp1Found = true;
    }
    if (ins.responsavel2 != null) {
      _resp2CpfController.text = ins.responsavel2!.cpf ?? '';
      _resp2NomeController.text = ins.responsavel2!.nome ?? '';
      _idInscResp2 = ins.responsavel2!.idInscricao;
      _resp2Found = true;
    }
  }

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
    _resp2CpfController.dispose();
    _resp2NomeController.dispose();
    super.dispose();
  }

  bool _isInfantil() {
    if (_dataNascimento == null) return false;
    final hoje = DateTime.now();
    int idade = hoje.year - _dataNascimento!.year;
    if (hoje.month < _dataNascimento!.month || (hoje.month == _dataNascimento!.month && hoje.day < _dataNascimento!.day)) {
      idade--;
    }
    return idade < widget.idadeMinimaAdulto;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdition ? 'Editar Inscrição' : 'Nova Inscrição'),
      content: SizedBox(
        width: 800,
        child: _isEdition ? SingleChildScrollView(child: _buildFullForm()) : _buildStepper(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        if (_isEdition)
          ElevatedButton(onPressed: _salvar, child: const Text('Salvar Alterações')),
      ],
    );
  }

  Widget _buildStepper() {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _nextStep,
      onStepCancel: _prevStep,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : details.onStepContinue,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_currentStep == 2 ? 'SALVAR' : 'PRÓXIMO'),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: details.onStepCancel, child: const Text('VOLTAR')),
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CPFInputFormatter(),
            ],
          ),
        ),
        Step(
          title: const Text('Nascimento'),
          isActive: _currentStep >= 1,
          content: Column(
            children: [
              TextField(controller: _cpfController, decoration: const InputDecoration(labelText: 'CPF'), enabled: false),
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
          title: const Text('Formulário'),
          isActive: _currentStep >= 2,
          content: _buildFullForm(),
        ),
      ],
    );
  }

  Widget _buildFullForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEdition) _buildReadOnlyInfo(),
          _buildSectionTitle('Dados Pessoais'),
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome Completo*'),
            validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail*'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'E-mail é obrigatório';
                    if (!_isValidEmail(v)) return 'E-mail inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _celularController,
                  decoration: const InputDecoration(labelText: 'Celular*'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _PhoneInputFormatter(),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Celular é obrigatório';
                    if (!_isValidPhone(v)) return 'Celular inválido (10 ou 11 dígitos)';
                    return null;
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(labelText: 'Cidade*'),
                  validator: (v) => v == null || v.isEmpty ? 'Cidade é obrigatória' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _ufController.text.isEmpty ? null : _ufController.text,
                  decoration: const InputDecoration(labelText: 'UF*'),
                  items: estadosBrasileiros
                      .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                      .toList(),
                  onChanged: (v) => setState(() => _ufController.text = v ?? ''),
                  validator: (v) => v == null || v.isEmpty ? 'UF é obrigatório' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<EnumSexo>(
                  initialValue: _sexo,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: EnumSexo.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (v) => setState(() => _sexo = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildCheckbox('Vegetariano', _ehVegetariano, (v) => setState(() => _ehVegetariano = v!)),
              _buildCheckbox('Diabético', _ehDiabetico, (v) => setState(() => _ehDiabetico = v!)),
              _buildCheckbox('Adoçante', _usaAdocante, (v) => setState(() => _usaAdocante = v!)),
            ],
          ),
          TextFormField(controller: _alergiasController, decoration: const InputDecoration(labelText: 'Alergias Alimentares')),
          
          _buildSectionTitle('Dados da Inscrição'),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _nomeCrachaController, decoration: const InputDecoration(labelText: 'Nome Crachá*'), validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null)),
              const SizedBox(width: 16),
              _buildCheckbox('Dormirá no Evento', _dormeEvento, (v) => setState(() => _dormeEvento = v!)),
            ],
          ),
          if (!_isInfantil()) ...[
            TextFormField(controller: _instituicaoController, decoration: const InputDecoration(labelText: 'Instituição Espírita')),
            DropdownButtonFormField<EnumTipoParticipante>(
              initialValue: _tipoParticipante,
              decoration: const InputDecoration(labelText: 'Tipo Participante'),
              items: EnumTipoParticipante.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _tipoParticipante = v),
            ),
          ],
          TextFormField(controller: _observacoesController, decoration: const InputDecoration(labelText: 'Observações'), maxLines: 2),

          if (_isInfantil()) ...[
            _buildSectionTitle('Responsáveis'),
            _buildResponsavelField(1, _resp1CpfController, _resp1NomeController, _resp1Found,
                    (found, idInscricao)  {
                      setState(() => _resp1Found = found);
                      _idInscResp1 = idInscricao;
                    }
            ),
            const SizedBox(height: 8),
            _buildResponsavelField(2, _resp2CpfController, _resp2NomeController, _resp2Found,
                    (found, idInscricao) {
                      setState(() => _resp2Found = found);
                      _idInscResp2 = idInscricao;
                    }
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResponsavelField(int index, TextEditingController cpfCtrl, TextEditingController nomeCtrl, bool found, Function(bool, int) setFound) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: cpfCtrl,
            decoration: InputDecoration(
              labelText: 'CPF Resp. $index${index == 1 ? '*' : ''}',
              suffixIcon: IconButton(
                icon: Icon(found ? Icons.clear : Icons.search),
                onPressed: () => found ? _limparResponsavel(cpfCtrl, nomeCtrl, setFound) : _buscarResponsavel(cpfCtrl, nomeCtrl, setFound),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CPFInputFormatter(),
            ],
            readOnly: found,
            validator: (v) {
              if (index == 1 && _isInfantil()) {
                if (v == null || v.isEmpty) return 'Obrigatório';
                if (!_isValidCPF(v)) return 'CPF inválido';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: nomeCtrl,
            decoration: InputDecoration(labelText: 'Nome Resp. $index'),
            readOnly: true,
          ),
        ),
      ],
    );
  }

  void _buscarResponsavel(TextEditingController cpfCtrl, TextEditingController nomeCtrl, Function(bool, int) setFound) async {
    if (cpfCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final res = await widget.inscricoesWS.pesquisar(widget.idEvento, cpfCtrl.text);
      setState(() => _isLoading = false);
      if (res.situacao != EnumSituacaoPesquisaPessoa.inscricaoNaoExiste && res.inscricao?.tipo == EnumTipoInscricao.adulto) {
        nomeCtrl.text = res.inscricao!.pessoa.nome;
        setFound(true, res.inscricao!.id!);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Responsável adulto não encontrado ou não inscrito.')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar: $e')));
    }
  }

  void _limparResponsavel(TextEditingController cpfCtrl, TextEditingController nomeCtrl, Function(bool, int) setFound) {
    cpfCtrl.clear();
    nomeCtrl.clear();
    setFound(false, 0);
  }

  Widget _buildReadOnlyInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(child: TextFormField(initialValue: _cpfController.text, decoration: const InputDecoration(labelText: 'CPF'), readOnly: true)),
          const SizedBox(width: 16),
          Expanded(child: TextFormField(initialValue: _dataNascimentoController.text, decoration: const InputDecoration(labelText: 'Data Nasc.'), readOnly: true)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Checkbox(value: value, onChanged: onChanged), Text(label)]);
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
      // Validar CPF
      String cpfLimpo = _cpfController.text.replaceAll(RegExp(r'\D'), '');
      if (cpfLimpo.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CPF é obrigatório')),
          );
        }
        return;
      }
      
      if (!_isValidCPF(cpfLimpo)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CPF inválido')),
          );
        }
        return;
      }
      
      // Pesquisar CPF no servidor
      setState(() => _isLoading = true);
      try {
        final res = await widget.inscricoesWS.pesquisar(widget.idEvento, cpfLimpo);
        setState(() => _isLoading = false);
        
        if (res == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao pesquisar CPF')),
            );
          }
          return;
        }
        
        // Verificar situação da inscrição
        if (res.situacao == EnumSituacaoPesquisaPessoa.inscricaoRealizada) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Já existe uma inscrição no sistema para este CPF')),
            );
          }
          return;
        }
        
        // Se for inscricaoNoLimbo ou inscricaoNaoExiste, prosseguir carregando dados
        if (res.situacao == EnumSituacaoPesquisaPessoa.inscricaoNoLimbo && res.inscricao != null) {
          // Guardar inscrição em limbo para atualizar depois
          _inscricaoEmLimbo = res.inscricao;
          
          // Carregar todos os dados da inscrição em limbo
          _nomeController.text = res.inscricao!.pessoa.nome;
          _emailController.text = res.inscricao!.pessoa.email;
          _celularController.text = res.inscricao!.pessoa.celular;
          _cidadeController.text = res.inscricao!.pessoa.cidade ?? '';
          _ufController.text = res.inscricao!.pessoa.uf ?? '';
          _sexo = res.inscricao!.pessoa.sexo;
          _ehVegetariano = res.inscricao!.pessoa.ehVegetariano;
          _ehDiabetico = res.inscricao!.pessoa.ehDiabetico;
          _usaAdocante = res.inscricao!.pessoa.usaAdocanteDiariamente;
          _alergiasController.text = res.inscricao!.pessoa.alergiaAlimentos ?? '';
          
          if (res.inscricao!.pessoa.dataNascimento != null) {
            _dataNascimento = res.inscricao!.pessoa.dataNascimento;
            _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(_dataNascimento!);
          }
        } else if (res.situacao == EnumSituacaoPesquisaPessoa.inscricaoNaoExiste && res.pessoa != null) {
          // Carregar dados da pessoa se retornou
          _nomeController.text = res.pessoa!.nome;
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
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao pesquisar: $e')),
          );
        }
      }
    } else if (_currentStep == 1) {
      if (_dataNascimento == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data de nascimento é obrigatória')),
          );
        }
        return;
      }
      setState(() => _currentStep++);
    } else {
      _salvar();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novaPessoa = DTOPessoa(
        nome: _nomeController.text,
        cpf: _cpfController.text.replaceAll(RegExp(r'\D'), ''),
        dataNascimento: _dataNascimento,
        email: _emailController.text,
        celular: _celularController.text.replaceAll(RegExp(r'\D'), ''),
        cidade: _cidadeController.text,
        uf: _ufController.text,
        sexo: _sexo,
        ehVegetariano: _ehVegetariano,
        ehDiabetico: _ehDiabetico,
        usaAdocanteDiariamente: _usaAdocante,
        alergiaAlimentos: _alergiasController.text,
      );

      // Decidir se vai atualizar inscrição em limbo ou criar nova
      final baseInscricao = _isEdition 
          ? widget.inscricao!
          : (_inscricaoEmLimbo ?? DTOInscricao(
              idEvento: widget.idEvento,
              tipo: _isInfantil() ? EnumTipoInscricao.infantil : EnumTipoInscricao.adulto,
              pessoa: novaPessoa,
              situacao: EnumSituacaoInscricao.limbo,
            ));

      final novaInscricao = baseInscricao.copyWith(
        pessoa: novaPessoa,
        nomeCracha: _nomeCrachaController.text,
        dormeEvento: _dormeEvento,
        instituicoesEspiritasFrequenta: !_isInfantil() ? _instituicaoController.text : null,
        tipoParticipante: _tipoParticipante,
        observacoes: _observacoesController.text,
        responsavel1: _resp1Found ? DTOResponsavel(idInscricao: _idInscResp1 ?? 0, cpf: _resp1CpfController.text.replaceAll(RegExp(r'\D'), ''), nome: _resp1NomeController.text) : null,
        responsavel2: _resp2Found ? DTOResponsavel(idInscricao:_idInscResp2 ?? 0, cpf: _resp2CpfController.text.replaceAll(RegExp(r'\D'), ''), nome: _resp2NomeController.text) : null,
      );
     
      widget.onSave(novaInscricao);
    }
  }
}

// Formatar de entrada para CPF (XXX.XXX.XXX-XX)
class _CPFInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }
    
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

// Formatar de entrada para telefone ((XX) XXXXX-XXXX)
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 0) {
        buffer.write('(');
      } else if (i == 2) {
        buffer.write(') ');
      } else if (i == 7) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }
    
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}
