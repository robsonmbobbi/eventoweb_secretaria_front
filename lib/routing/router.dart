import 'package:eventoweb_secretaria_front/routing/routes.dart';
import 'package:eventoweb_secretaria_front/domain/auth_controller.dart';
import 'package:eventoweb_secretaria_front/ui/event_home/widgets/event_home_screen.dart';
import 'package:eventoweb_secretaria_front/ui/home/widgets/home_screen.dart';
import 'package:eventoweb_secretaria_front/ui/inscricoes/listagem/widgets/inscricoes_listagem_screen.dart';
import 'package:eventoweb_secretaria_front/ui/pedidos/cadastro/view_model/pedido_cadastro_viewmodel.dart';
import 'package:eventoweb_secretaria_front/ui/pedidos/cadastro/widgets/pedido_cadastro_screen.dart';
import 'package:eventoweb_secretaria_front/ui/shell/widgets/shell_screen.dart';
import 'package:eventoweb_secretaria_front/ui/login/widgets/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ui/event_shell/widgets/event_shell_screen.dart';

class GenerationRouter {
  final AuthController _authController;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  GenerationRouter(this._authController);

  GoRouter generate() {
    return GoRouter(
      initialLocation: Routes.home,
      navigatorKey: navigatorKey,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: _authController,
      routes: [
        GoRoute(
          path: Routes.login,
          builder: (context, state) {
            return LoginScreen(context.read());
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            return ShellScreen(homeViewModel: context.read(), child: child);
          },
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) {
                return HomeScreen(context.read());
              },
              routes: [
                ShellRoute(
                  builder: (context, state, child) {
                    var idEvento = int.parse(state.pathParameters["idEvento"] ?? "-1");
                    return EventShellScreen(context.read(), idEvento, child);
                  },
                  routes: [
                    GoRoute(
                      path: "/evento/:idEvento",
                      builder: (context, state) {
                        return EventHomeScreen(context.read());
                      },
                    ),
                    GoRoute(
                      path: "/evento/:idEvento/inscricoes",
                      builder: (context, state) {
                        return InscricoesListagemScreen(viewModel: context.read());
                      },
                    ),
                    GoRoute(
                      path: "/evento/:idEvento/pedidos/novo",
                      builder: (context, state) {
                        return PedidoCadastroScreen(
                          viewModel: PedidoCadastroViewModel(
                            inscricoesWS: context.read(),
                            precosWS: context.read(),
                            formasPagamentoWS: context.read(),
                            pedidosWS: context.read(),
                            eventViewModel: context.read(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    // if the user is not logged in, they need to login
    final loggedIn = await _authController.isAuthenticated;
    final loggingIn = state.matchedLocation == Routes.login;
    if (!loggedIn) {
      return Routes.login;
    }

    // if the user is logged in but still on the login page, send them to
    // the home page
    if (loggingIn) {
      return Routes.home;
    }

    // no need to redirect at all
    return state.path;
  }
}
