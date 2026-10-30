import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/models/chat_message.dart';
import 'package:ai_chatbot/features/chat/widgets/active_conversation_card.dart';
import 'package:ai_chatbot/features/chat/widgets/chat_composer.dart';
import 'package:ai_chatbot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_controller_test.dart' show ControlledApi;

void main() {
  testWidgets('reply does not interrupt a fling through older messages', (
    tester,
  ) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    for (var i = 0; i < 20; i++) {
      final request = controller.sendMessage('Pertanyaan $i');
      api.responses.last.complete(ChatReply(reply: 'Jawaban $i'));
      await request;
    }
    await tester.pumpWidget(MyApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 400));
    final pending = controller.sendMessage('Pertanyaan berikutnya');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 450),
      1000,
    );
    await tester.pump(const Duration(milliseconds: 16));
    final position = controller.scrollController.position;
    expect(position.isScrollingNotifier.value, isTrue);
    api.responses.last.complete(const ChatReply(reply: 'Jawaban berikutnya'));
    await pending;
    await tester.pump(const Duration(milliseconds: 16));
    expect(position.isScrollingNotifier.value, isTrue);
    expect(position.pixels, greaterThan(80));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets('long Markdown can be read from start to end at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ControlledApi();
      final controller = ChatController(api: api);
      await tester.pumpWidget(MyApp(controller: controller));
      final pending = controller.sendMessage('Daftar produk');
      await tester.pump(const Duration(milliseconds: 400));
      api.responses.single.complete(
        ChatReply(
          reply:
              '**Awal jawaban**\n\n${List.generate(60, (i) => '- Produk $i beserta informasi lengkapnya.').join('\n')}\n\nParagraf terakhir.',
          responseTimeMs: 1250,
        ),
      );
      await pending;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final viewport = tester.getRect(find.byType(CustomScrollView));
      final composer = tester.getRect(find.byType(ChatComposer));
      final finalParagraph = find.text('Paragraf terakhir.');
      final responseTime = find.text('Waktu respons: 1.3 detik');
      expect(tester.getRect(finalParagraph).top, greaterThan(viewport.top));
      expect(tester.getRect(responseTime).bottom, lessThan(viewport.bottom));
      expect(viewport.bottom, lessThanOrEqualTo(composer.top));
      // Exercise the conversation's scrollable, rather than a nested text field.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(controller.scrollController.offset, greaterThan(80));
      controller.scrollController.jumpTo(
        controller.scrollController.position.maxScrollExtent,
      );
      await tester.pumpAndSettle();
      final firstParagraph = find.text('Awal jawaban');
      expect(tester.getRect(firstParagraph).bottom, greaterThan(viewport.top));
      expect(tester.getRect(firstParagraph).top, lessThan(viewport.bottom));
      controller.scrollToLatest();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(controller.scrollController.offset, 0);
      expect(tester.getRect(responseTime).bottom, lessThan(composer.top));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'sidebar title and scroll belong to the current session at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = ControlledApi();
        final controller = ChatController(api: api);
        await tester.pumpWidget(MyApp(controller: controller));
        Future<void> openSidebar() async {
          if (size.width < 760) {
            await tester.tap(find.byTooltip('Buka menu'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
          }
        }

        await openSidebar();
        expect(
          tester
              .widget<ActiveConversationCard>(
                find.byType(ActiveConversationCard),
              )
              .hasMessages,
          isFalse,
        );
        if (size.width < 760) {
          Navigator.of(tester.element(find.byType(ActiveConversationCard)))
              .pop();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
        }
        final pending = controller.sendMessage('  Judul sesi pertama  ');
        await tester.pump(const Duration(milliseconds: 400));
        api.responses.last.complete(
          ChatReply(reply: List.filled(45, 'Jawaban panjang.').join('\n\n')),
        );
        await pending;
        await tester.pump();
        await tester.pumpAndSettle();
        controller.scrollController.jumpTo(250);
        await tester.pumpAndSettle();
        await openSidebar();
        final card = tester.widget<ActiveConversationCard>(
          find.byType(ActiveConversationCard),
        );
        expect(card.title, 'Judul sesi pertama');
        expect(card.hasMessages, isTrue);
        await tester.tap(find.text('Kembali ke percakapan'));
        await tester.pumpAndSettle();
        expect(controller.scrollController.offset, 0);
        await openSidebar();
        await tester.tap(find.text('Chat Baru').first);
        await tester.pump(const Duration(milliseconds: 400));
        expect(controller.messages, isEmpty);
        expect(controller.scrollController.hasClients, isFalse);
        final next = controller.sendMessage('Judul sesi kedua');
        await tester.pump(const Duration(milliseconds: 400));
        expect(controller.scrollController.offset, 0);
        api.responses.last.complete(
          const ChatReply(reply: 'Jawaban sesi kedua.'),
        );
        await next;
        await tester.pump();
        await tester.pumpAndSettle();
        await openSidebar();
        expect(
          tester
              .widget<ActiveConversationCard>(
                find.byType(ActiveConversationCard),
              )
              .title,
          'Judul sesi kedua',
        );
        expect(find.text('Judul sesi pertama'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
