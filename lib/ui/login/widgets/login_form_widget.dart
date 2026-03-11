import 'package:flutter/material.dart';

typedef LoginCallBack = void Function(String? userName, String? password);

class LoginFormWidget extends StatelessWidget {
  LoginFormWidget({super.key, required this.processing, required this.onLogin, 
                   String? userName, String? password, this.versionApp}) {
      _userNameController = TextEditingController(text: userName);
      _passwordController = TextEditingController(text: password);
    }

  late final TextEditingController _userNameController;
  late final TextEditingController _passwordController;
  final bool processing;  
  final LoginCallBack onLogin;
  final String? versionApp;
  final _formKey = GlobalKey<FormState>();  

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 12.0,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Usuário:',
            ),
            controller: _userNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Usuário não informado';
              }

              return null;              
            },
            autovalidateMode: AutovalidateMode.onUnfocus,
            enabled: !processing,
            onFieldSubmitted: (_) => _authenticate(),
          ),
          TextFormField(     
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            enableInteractiveSelection: false, 
            controller: _passwordController,          
            decoration: InputDecoration(
              labelText: 'Senha:',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha não informada';
              }

              return null;              
            },
            autovalidateMode: AutovalidateMode.onUnfocus,
            enabled: !processing,
            onFieldSubmitted: (_) => _authenticate(),
          ),
          processing 
            ? _generateProcessingPanel() 
            : _generateCommandButton(),
          Text(
            'Versão: ${(versionApp ?? "Versão não informada")}',
            style: Theme.of(context).textTheme.bodySmall
          )
        ],
      ),
    );
  }

   Widget _generateProcessingPanel() {
    return const CircularProgressIndicator(
      value: null,
      strokeWidth: 5.0,
      semanticsLabel: 'Processando autenticação',
    );
  }
  
  Widget _generateCommandButton() {
    return SizedBox(
      width: double.infinity ,
      child: ElevatedButton(      
        onPressed: () => _authenticate(),
        child: const Text('AUTENTICAR'),
      )
    );
  }

  void _authenticate() {
    if (_formKey.currentState!.validate()) {
      onLogin(_userNameController.text, _passwordController.text);
    }
  } 
}