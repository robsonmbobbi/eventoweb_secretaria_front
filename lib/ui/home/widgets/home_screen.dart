import 'package:eventoweb_secretaria_front/ui/core/ui/loading_overlay.dart';
import 'package:eventoweb_secretaria_front/ui/home/view_model/home_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/home/widgets/event_card.dart';
import 'package:eventoweb_secretaria_front/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../core/ui/message_panel_widget.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen(this.viewModel, {super.key});

  @override
  State<StatefulWidget> createState()  => _HomeStateScreen();
}

class _HomeStateScreen extends State<HomeScreen> {

  @override
  void initState() {

    Future.microtask(() => widget.viewModel.comandoListarTodosEventos.execute());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5),
      child: ListenableBuilder(
          listenable: Listenable.merge([widget.viewModel, widget.viewModel.comandoListarTodosEventos]),
          builder: (ctx, child) {

            if (widget.viewModel.comandoListarTodosEventos.error) {
              var errorCmd = widget.viewModel.comandoListarTodosEventos.result as ErrorCommand;
              widget.viewModel.comandoListarTodosEventos.clearResult();

              return MessagePanelWidget(
                  message: 'Ocorreu um problema!!\n${errorCmd.error}',
                  type: MessagePanelType.error
              );
            }

            return LoadingOverlay(
              isLoading: widget.viewModel.comandoListarTodosEventos.running,
              child: Wrap(
                  spacing: 5,
                  children: [
                    if (widget.viewModel.eventos.isEmpty)
                      MessagePanelWidget(
                        message: 'Não há eventos por aqui!!!',
                        type: MessagePanelType.info
                      )
                    else
                      ...widget
                          .viewModel
                          .eventos
                          .map((e) {
                            return SizedBox(
                              width: 500,
                              child: Link(
                                uri: Uri.parse("/evento/${e.id!}"),
                                target: LinkTarget.self,
                                builder: (ctxLink, follow) => EventCard(evento: e, onGerenciarClick: follow!),
                                ),
                              );
                          }
                      )
                  ]
              )
            );
          }
      )
    );
  }
}
//

