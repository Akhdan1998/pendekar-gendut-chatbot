import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/chat/controllers/chat_controller.dart';
import '../../features/chat/views/chat_page.dart';
import '../../features/landing/views/landing_page.dart';

class AppRouteParser extends RouteInformationParser<String> {
  const AppRouteParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(routeInformation.uri.path == '/chat' ? '/chat' : '/');

  @override
  RouteInformation restoreRouteInformation(String configuration) =>
      RouteInformation(uri: Uri.parse(configuration));
}

class AppRouter extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  AppRouter({this.controller})
    : _chat =
          WidgetsBinding.instance.platformDispatcher.defaultRouteName ==
          '/chat';

  final ChatController? controller;
  bool _chat;

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  String get currentConfiguration => _chat ? '/chat' : '/';

  void openChat() {
    _chat = true;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _chat = configuration == '/chat';
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: [
      MaterialPage<void>(
        key: const ValueKey('landing'),
        child: LandingPage(onStartChat: openChat),
      ),
      if (_chat)
        MaterialPage<void>(
          key: const ValueKey('chat'),
          child: ChatPage(controller: controller),
        ),
    ],
    onDidRemovePage: (page) {
      if (page.key == const ValueKey('chat') && _chat) {
        _chat = false;
        notifyListeners();
      }
    },
  );
}
