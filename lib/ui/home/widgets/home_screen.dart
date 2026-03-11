import 'package:eventoweb_secretaria_front/ui/core/themes/theme_button_menu.dart';
import 'package:eventoweb_secretaria_front/ui/shell/view_model/shell_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class HomeScreen extends StatelessWidget {
  final ShellViewModel _shellViewModel;

  const HomeScreen(this._shellViewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final themeButtonMenu = Theme.of(context).extension<ThemeButtonMenu>();

    return Text("");
  }
}
