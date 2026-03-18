import 'package:eventoweb_secretaria_front/ui/core/ui/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../../utils/result.dart';
import '../../core/themes/theme_button_menu.dart';
import '../../core/ui/message_panel_widget.dart';
import '../../event_shell/view_model/event_shell_viewmodel.dart';

class EventHomeScreen extends StatefulWidget {
  final EventShellViewModel viewModel;

  const EventHomeScreen(this.viewModel, {super.key});

  @override
  State<StatefulWidget> createState()  => _EventHomeStateScreen();
}

class _EventHomeStateScreen extends State<EventHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final themeButtonMenu = Theme.of(context).extension<ThemeButtonMenu>();

    return ListenableBuilder(
      listenable: Listenable.merge([widget.viewModel, widget.viewModel.atribuirEventoComando]),
      builder: (ctx, child) {

        if (widget.viewModel.atribuirEventoComando.error) {
          var errorCmd = widget.viewModel.atribuirEventoComando.result as ErrorCommand;
          widget.viewModel.atribuirEventoComando.clearResult();

          return MessagePanelWidget(
              message: 'Ocorreu um problema!!\n${errorCmd.error}',
              type: MessagePanelType.error
          );
        }

        return LoadingOverlay(
          isLoading: widget.viewModel.atribuirEventoComando.running,
          child: SingleChildScrollView(
              padding: EdgeInsets.all(5),
              child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Link(
                      uri: Uri.parse("/evento/${widget.viewModel.eventoEscolhido?.id ?? "0"}/inscricoes"),
                      target: LinkTarget.self,
                      builder: (ctxLink, follow) => ElevatedButton(
                        style: themeButtonMenu?.theme,
                        onPressed: follow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.app_registration,
                              size: 60,
                            ),
                            const SizedBox(height: 8),
                            Text("Inscrições"),
                          ],
                        ),
                      ),
                    )
                  ]
              )
          ),
        );
      }
    );
  }
}