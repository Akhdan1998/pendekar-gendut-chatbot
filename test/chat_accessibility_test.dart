import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/models/chat_message.dart';

import 'features/chat/chat_controller_test.dart' show ControlledApi;

import 'package:flutter_test/flutter_test.dart';

import 'support/pump_chat_app.dart';

void main() {
  testWidgets('reply completion is announced while reading older messages', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final api = ControlledApi();
    final controller = ChatController(api: api);
    for (var i = 0; i < 15; i++) {
      final pending = controller.sendMessage('Pertanyaan $i');
      api.responses.last.complete(ChatReply(reply: 'Jawaban $i'));
      await pending;
    }
    await pumpChatApp(tester, controller: controller);
    await tester.pump(const Duration(milliseconds: 400));
    final pending = controller.sendMessage('Pertanyaan baru');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 450));
    await tester.pump(const Duration(seconds: 1));
    api.responses.last.complete(
      ChatReply(reply: List.filled(30, 'Jawaban terbaru.').join('\n')),
    );
    await pending;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final announcement = find.bySemanticsLabel(
      'Jawaban baru tersedia dari Pendekar Gendut.',
    );
    expect(announcement, findsOneWidget);
    expect(
      tester.getSemantics(announcement).flagsCollection.isLiveRegion,
      isTrue,
    );
    expect(find.text('Jawaban terbaru.'), findsNothing);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('keyboard focus returns to composer after a successful answer', (
    tester,
  ) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    await pumpChatApp(tester, controller: controller);
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Halo');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 400));
    api.responses.single.complete(const ChatReply(reply: 'Halo kembali.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.inputFocus.hasFocus, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  for (final keyboard in [0.0, 260.0]) {
    testWidgets('chat fits 320x568 with 200% text and keyboard $keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpChatApp(tester);
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField), 'Satu\nDua\nTiga\nEmpat');
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(
        tester.getBottomRight(find.byType(TextField)).dy,
        lessThanOrEqualTo(568 - keyboard),
      );
      expect(
        tester.getTopLeft(find.byType(TextField)).dy,
        greaterThanOrEqualTo(0),
      );
      await tester.pumpWidget(const SizedBox());
    });
  }
}
