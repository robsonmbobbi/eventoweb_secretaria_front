import 'dart:convert';

import 'package:eventoweb_secretaria_front/data/repositories/events/events_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/contas_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/contas_bancarias_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/financeiro/formas_pagamento_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/inscricoes/precos_inscricao_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/pedidos/pedidos_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/registros_integracao/registros_integracao_ws.dart';
import 'package:eventoweb_secretaria_front/data/repositories/security/auth_repository.dart';
import 'package:eventoweb_secretaria_front/data/repositories/version_app_repository.dart';
import 'package:eventoweb_secretaria_front/data/repositories/ws_client.dart';
import 'package:eventoweb_secretaria_front/domain/auth_controller.dart';
import 'package:eventoweb_secretaria_front/ui/core/themes/theme_back_button.dart';
import 'package:eventoweb_secretaria_front/ui/core/themes/theme_button_menu.dart';
import 'package:eventoweb_secretaria_front/ui/event_shell/view_model/event_shell_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/home/view_model/home_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/view_model/inscricoes_listagem_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/login/view_model/login_viewmodel.dart';
import 'package:eventoweb_secretaria_front/data/repositories/security/auth_ws.dart';
import 'package:eventoweb_secretaria_front/routing/router.dart';
import 'package:eventoweb_secretaria_front/ui/shell/view_model/shell_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/usuarios/listagem/view_model/usuarios_listagem_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/repositories/inscricoes/inscricoes_ws.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  var json = jsonDecode(await rootBundle.loadString('assets/config.json'));

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => WSClient(json["urlApi"])),
        Provider(create: (context) => AuthRepository()),
        Provider(create: (context) => VersionAppRepository()),
        Provider(create: (context) => AuthWS(context.read())),
        Provider(create: (context) => EventsWS(context.read(), context.read())),
        Provider(create: (context) => InscricoesWS(context.read(), context.read())),
        Provider(create: (context) => PedidosWS(context.read(), context.read())),
        Provider(create: (context) => RegistrosIntegracaoWS(context.read(), context.read())),
        Provider(create: (context) => PrecosInscricaoWS(context.read(), context.read())),
        Provider(create: (context) => FormasPagamentoWS(context.read(), context.read())),
        Provider(create: (context) => ContasWS(context.read(), context.read())),
        Provider(create: (context) => ContasBancariasWS(context.read(), context.read())),
        ChangeNotifierProvider(
          create: (context) => AuthController(context.read(), context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read(), context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => ShellViewModel(context.read(), context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => UsuariosListagemViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => EventShellViewModel(context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => InscricoesListagemViewModel(
            eventViewModel: context.read(), 
            inscricoesWS: context.read(),
            pedidosWS: context.read(),
            registrosIntegracaoWS: context.read(),
            formasPagamentoWS: context.read(),
            contasWS: context.read(),
            contasBancariasWS: context.read(),
          ),
        ),
      ],
      child: const SecretariaApp(),
    ),
  );
}

class SecretariaApp extends StatelessWidget {
  const SecretariaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
    ).copyWith(surface: Colors.white);

    var generateRouter = GenerationRouter(context.read());

    return MaterialApp.router(
      title: 'EventoWeb - Secretaria',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      theme: ThemeData(
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(color: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(color: colorScheme.surface),
        drawerTheme: DrawerThemeData(backgroundColor: colorScheme.surface),
        useMaterial3: true,
        extensions: [
          ThemeButtonMenu(
            foregroundColor: colorScheme.shadow,
            backgroundColor: colorScheme.surface,
            borderColor: colorScheme.primary,
          ),
          ThemeBackButton(
            backgroundColor: Color(0xFF337ab7),
            foregroundColor: Colors.white,
          ),
        ],
      ),
      routerConfig: generateRouter.generate(),
    );
  }
}
