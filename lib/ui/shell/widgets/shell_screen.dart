import 'package:eventoweb_secretaria_front/ui/core/themes/theme_button_menu.dart';
import 'package:eventoweb_secretaria_front/ui/shell/view_model/shell_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  final ShellViewModel homeViewModel;

  const ShellScreen({
    super.key,
    required this.child,
    required this.homeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Secretaria - EventoWeb"),
            FutureBuilder(
              future: homeViewModel.versionApp,
              builder: (ctx, snapshot) {
                return Padding(
                  padding: EdgeInsetsGeometry.directional(start: 24.0),
                  child: Text(
                    "Versão: ${snapshot.data ?? "Desconhecida"}",
                    style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.surface,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.person, size: 40),
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'change_data',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8),
                    Text('Alterar dados'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(
                      Icons.key,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8),
                    Text('Alterar senha'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                onTap: () => homeViewModel.logout(),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 50,
              color: Theme.of(context).colorScheme.primary,
              child: Center(
                child: Text(
                  "Menu",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: _generateMenu(context)),
          ],
        ),
      ),
      body: SafeArea(child: child),
    );
  }

  Widget _generateMenu(BuildContext context) {
    final themeButtonMenu = Theme.of(context).extension<ThemeButtonMenu>();

    return Text("");
  }
}
