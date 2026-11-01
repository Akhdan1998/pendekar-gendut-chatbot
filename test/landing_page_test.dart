import 'package:ai_chatbot/main.dart';
import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/views/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'direct chat URL and browser back and forward choose the right page',
    (tester) async {
      tester.binding.platformDispatcher.defaultRouteNameTestValue = '/chat';
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ChatPage), findsOneWidget);
      await tester.binding.handlePushRoute('/');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ChatPage), findsNothing);
      expect(find.text('Asisten AI untuk UMKM.'), findsOneWidget);
      await tester.binding.handlePushRoute('/chat');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ChatPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('landing supports enlarged mobile text and keyboard activation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.pump();
    final button = find.widgetWithText(FilledButton, 'Coba AI').first;
    Focus.of(
      tester.element(find.descendant(of: button, matching: find.byType(Text))),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ChatPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'injected chat controller remains usable after leaving and reopening chat',
    (tester) async {
      tester.binding.platformDispatcher.defaultRouteNameTestValue = '/chat';
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      final controller = ChatController();
      await tester.pumpWidget(MyApp(controller: controller));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField), 'Draf pertanyaan');
      await tester.binding.handlePushRoute('/');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.binding.handlePushRoute('/chat');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'Draf baru');
      expect(controller.inputController.text, 'Draf baru');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('rapid browser back and forward leaves one usable chat page', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    for (final route in ['/chat', '/', '/chat', '/', '/chat']) {
      await tester.binding.handlePushRoute(route);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ChatPage), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 390.0, 768.0, 946.0, 1440.0]) {
    testWidgets('landing fits $width and CTA opens chat with back navigation', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Asisten AI untuk UMKM.'), findsOneWidget);
      expect(find.text('Pratinjau Chatbot'), findsOneWidget);
      expect(find.text('Teknologi yang Digunakan'), findsOneWidget);
      expect(
        find.text('Demonstrasi · bukan percakapan langsung'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Jelajahi Fitur'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Apa yang Bisa Dilakukan?').hitTestable(),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Mulai Percakapan'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Mulai Percakapan'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ChatPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Kembali ke Beranda'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ChatPage), findsNothing);
      expect(find.text('Asisten AI untuk UMKM.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
