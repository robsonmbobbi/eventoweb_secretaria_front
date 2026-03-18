import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/result.dart';
import '../../core/ui/message_panel_widget.dart';
import '../view_model/event_shell_viewmodel.dart';

class EventShellScreen extends StatefulWidget {
  final EventShellViewModel viewModel;
  final int idEvento;
  final Widget child;

  const EventShellScreen(this.viewModel, this.idEvento, this.child, {super.key});

  @override
  State<StatefulWidget> createState()  => _EventShellStateScreen();
}

class _EventShellStateScreen extends State<EventShellScreen> {

  @override
  void initState() {

    Future.microtask(() => widget.viewModel.atribuirEventoComando.execute(widget.idEvento));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, size: 30),
              onPressed: () => context.pop(),
            ),
            SizedBox(width: 15),
            ListenableBuilder(
              listenable: widget.viewModel.atribuirEventoComando,
              builder: (ctx, child) {
                if (widget.viewModel.atribuirEventoComando.error) {
                  var errorCmd = widget.viewModel.atribuirEventoComando.result as ErrorCommand;
                  widget.viewModel.atribuirEventoComando.clearResult();

                  return MessagePanelWidget(
                      message: 'Ocorreu um problema!!\n${errorCmd.error}',
                      type: MessagePanelType.error
                  );
                }

                return Text(
                  widget.viewModel.atribuirEventoComando.running ?
                      "Carregando..." : widget.viewModel.eventoEscolhido?.nome ?? "Vazio",
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),
          ],
        ),
        SizedBox(height: 15),
        Expanded(
          child: widget.child,
        )
      ],
    );
  }
}


