import 'package:eventoweb_secretaria_front/ui/login/view_model/login_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/login/widgets/login_widget_desktop.dart';
import 'package:eventoweb_secretaria_front/ui/login/widgets/login_widget_mobile.dart';
import 'package:eventoweb_secretaria_front/ui/core/ui/reponsive/responsive_layout.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {

  final LoginViewModel _controller;

  const LoginScreen(this._controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayout(
          mobileBody: LoginWidgetMobile(_controller), 
          desktopBody: LoginWidgetDesktop(_controller)
        )
      )
    );
  }
}