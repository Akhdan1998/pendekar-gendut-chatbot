import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/routing/app_router.dart';

import 'core/theme/app_theme.dart';
import 'features/chat/controllers/chat_controller.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.controller});
  final ChatController? controller;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _router = AppRouter(controller: widget.controller);

  @override
  void dispose() {
    _router.dispose();
    widget.controller?.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Pendekar Gendut AI | Toko H Haris',
    debugShowCheckedModeBanner: false,
    locale: const Locale('id', 'ID'),
    supportedLocales: const [Locale('id', 'ID')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: AppTheme.dark,
    routerDelegate: _router,
    routeInformationParser: const AppRouteParser(),
  );
}
