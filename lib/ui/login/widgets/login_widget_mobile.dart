import 'package:eventoweb_secretaria_front/ui/core/ui/message_panel_widget.dart';
import 'package:eventoweb_secretaria_front/ui/login/view_model/login_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/login/widgets/login_form_widget.dart';
import 'package:flutter/material.dart';

class LoginWidgetMobile extends StatefulWidget {
  
  final LoginViewModel viewModel;

  const LoginWidgetMobile(this.viewModel, { super.key, });

  @override
  State<LoginWidgetMobile> createState() => _LoginWidgetMobileState();
}

class _LoginWidgetMobileState extends State<LoginWidgetMobile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel, 
      builder: (context, _) {
        return Padding(
          padding:const EdgeInsets.all(8.0),
          child: Column(          
            children: [
              if (widget.viewModel.error != null)
                MessagePanelWidget(
                  message: 'Ocorreu um erro!!\n ${widget.viewModel.error}', 
                  type: MessagePanelType.error
                ),
              if (widget.viewModel.validationMessages != null)
                MessagePanelWidget(
                  message: widget.viewModel.validationMessages!, 
                  type: MessagePanelType.warning
                ),

              const Icon(Icons.login, size: 70),
              FutureBuilder(
                future: widget.viewModel.versionApp, 
                builder: (ctx, builder) {
                  return LoginFormWidget(
                    processing: widget.viewModel.processing, 
                    userName: widget.viewModel.userName,
                    password: widget.viewModel.password,
                    versionApp: builder.data,
                    onLogin: (userName, password) {
                      widget.viewModel.login(userName, password);
                    },
                  );
                }
              ) 
            ]
          ) 
        );
      }
    );
  }
}