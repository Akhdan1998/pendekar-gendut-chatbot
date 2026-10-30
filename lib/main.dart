import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/chat/views/chat_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.controller});
  final ChatController? controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'UMKM AI Chatbot | Toko H Haris',
    debugShowCheckedModeBanner: false,
    locale: const Locale('id', 'ID'),
    supportedLocales: const [Locale('id', 'ID')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: AppTheme.dark,
    home: ChatPage(controller: controller),
  );
}
