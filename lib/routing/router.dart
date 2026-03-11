import 'package:eventoweb_secretaria_front/routing/routes.dart';
import 'package:eventoweb_secretaria_front/domain/auth_controller.dart';
import 'package:eventoweb_secretaria_front/ui/home/widgets/home_screen.dart';
import 'package:eventoweb_secretaria_front/ui/shell/widgets/shell_screen.dart';
import 'package:eventoweb_secretaria_front/ui/login/widgets/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GenerationRouter {
  final AuthController _authController;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  GenerationRouter(this._authController) {
  }

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
