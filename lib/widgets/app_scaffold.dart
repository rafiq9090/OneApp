import 'package:flutter/material.dart';
import 'package:flutter_application_1/Controller/theme_controller.dart';
import 'package:flutter_application_1/myDrawer.dart';
import 'package:get/get.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBack = true,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: const myDrawer(),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          if (actions != null) ...actions!,
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.palette_outlined),
            onSelected: (mode) =>
                Get.find<ThemeController>().setMode(mode),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System default'),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Light mode'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark mode'),
              ),
            ],
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            child: child,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
