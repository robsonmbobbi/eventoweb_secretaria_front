import 'package:eventoweb_secretaria_front/ui/core/themes/theme_back_button.dart';
import 'package:eventoweb_secretaria_front/ui/usuarios/listagem/view_model/usuarios_listagem_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_split_view/multi_split_view.dart';

class UsuariosListagemScreen extends StatefulWidget {
  final UsuariosListagemViewModel viewModel;

  const UsuariosListagemScreen(this.viewModel, {super.key});

  @override
  State<UsuariosListagemScreen> createState() => _UsuariosListagemScreenState();
}

class _UsuariosListagemScreenState extends State<UsuariosListagemScreen> {
  @override
  Widget build(BuildContext context) {
    final buttonBackStyle = Theme.of(context).extension<ThemeBackButton>();

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.directional(
            start: 3.0,
            end: 3.0,
            top: 3.0,
            bottom: 0.0,
          ),
          child: Row(
            spacing: 5,
            children: [
              ElevatedButton(
                onPressed: () => context.pop(),
                style: buttonBackStyle?.theme,
                child: Row(
                  spacing: 2.0,
                  children: [Icon(Icons.arrow_back), Text('Voltar')],
                ),
              ),
              Image(image: AssetImage("assets/menuUsr.png"), width: 30),
              Text(
                'Usuários',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Expanded(child: SizedBox()),
              ElevatedButton(
                onPressed: () => {},
                style: buttonBackStyle?.theme,
                child: Row(
                  spacing: 2.0,
                  children: [Icon(Icons.add), Text('Novo')],
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsetsGeometry.directional(
            start: 3.0,
            end: 3.0,
            top: 0.0,
            bottom: 0.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  decoration: InputDecoration(labelText: 'Nome Usuário:'),
                ),
              ),
              TextField(decoration: InputDecoration(labelText: 'Nome:')),
              Row(
                children: [
                  Expanded(child: SizedBox()),
                  ElevatedButton(
                    onPressed: () => {},
                    style: buttonBackStyle?.theme,
                    child: Row(
                      spacing: 2.0,
                      children: [Icon(Icons.search), Text('Pesquisar')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: MultiSplitViewTheme(
            data: MultiSplitViewThemeData(
              dividerPainter: DividerPainters.grooved2(),
            ),
            child: MultiSplitView(
              axis: Axis.horizontal,
              pushDividers: true,
              controller: MultiSplitViewController(
                areas: [Area(flex: 0.75), Area(flex: 0.25)],
              ),
              builder: (context, area) {
                if (area.index == 0) {
                  return Container(
                    //width: MediaQuery.of(context).size.width * 0.7,
                    color: Colors.grey[200],
                    child: Text('DataGrid'),
                  );
                } else {
                  return Column(
                    children: [
                      Row(children: [Text('Ações')]),
                      Container(
                        color: Colors.grey[200],
                        child: Text('Detalhes'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
