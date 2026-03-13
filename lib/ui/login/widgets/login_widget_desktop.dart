import 'package:eventoweb_secretaria_front/ui/core/ui/message_panel_widget.dart';
import 'package:eventoweb_secretaria_front/ui/login/view_model/login_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/login/widgets/login_form_widget.dart';
import 'package:flutter/material.dart';

class LoginWidgetDesktop extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginWidgetDesktop(this.viewModel, { super.key, });

  @override
  State<LoginWidgetDesktop> createState() => _LoginWidgetDesktopState();
}

class _LoginWidgetDesktopState extends State<LoginWidgetDesktop> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,      
      children: [
        Center(
          child:SizedBox(
            width: 400,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListenableBuilder(
                  listenable: widget.viewModel, 
                  builder: (context, _) {
                    return Column(
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
                    );
                  }
                ) 
              )
            )
          )
        ),             
      ],
    );
  }  

  
                      /*
                      import 'package:url_launcher/link.dart';

                      Link(
                      uri: Uri.parse('https://androidride.com/flutter-hyperlink-text/'),
                      builder: (context, followLink) {
                        return ElevatedButton(
                          onPressed: followLink,
                          child: Text(
                            'Teste',
                            style: TextStyle(
                              fontSize: 20,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        );
                      },
                    ),*/
}