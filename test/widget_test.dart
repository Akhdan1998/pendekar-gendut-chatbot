import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/widgets/typing_indicator.dart';
import 'package:ai_chatbot/features/chat/widgets/chat_bubble.dart';
import 'package:ai_chatbot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/chat/chat_controller_test.dart' show ControlledApi;

import 'package:ai_chatbot/features/chat/models/chat_message.dart';
import 'package:ai_chatbot/features/chat/services/chat_api_service.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(900, 800),
    const Size(390, 844),
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    testWidgets(
      'welcome fits viewport $size and menu keeps Chat Baru accessible',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = ControlledApi();
        final controller = ChatController(api: api);
        await tester.pumpWidget(MyApp(controller: controller));
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.text(
            'Halo! Saya Pendekar Gendut, pelayan virtual Toko H Haris. Ada yang bisa saya bantu?',
          ),
          findsOneWidget,
        );
        expect(find.text('Produk apa saja yang tersedia?'), findsOneWidget);
        expect(find.text('Pendekar Gendut'), findsOneWidget);
        expect(find.text('Asisten UMKM'), findsNothing);
        expect(controller.messages, isEmpty);
        expect(tester.takeException(), isNull);
        final pending = controller.sendMessage('Harga beras?');
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          find.text('Pendekar Gendut sedang menyiapkan jawaban…'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        api.responses.single.complete(
          const ChatReply(reply: 'Jawaban uji dari API.'),
        );
        await pending;
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Pendekar Gendut'), findsNWidgets(2));
        expect(find.text('Jawaban uji dari API.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (size.width < 760) {
          await tester.tap(find.byTooltip('Buka menu'));
          await tester.pump(const Duration(milliseconds: 400));
        }
        expect(find.text('Chat Baru'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'suggestion sends, loading appears, failure retries, and new chat resets',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ControlledApi();
      final controller = ChatController(api: api);
      await tester.pumpWidget(MyApp(controller: controller));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Produk apa saja yang tersedia?'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(api.requests.single.message, 'Produk apa saja yang tersedia?');
      expect(find.byType(TypingIndicator), findsOneWidget);
      api.responses.single.completeError(
        const ChatApiException('Tidak dapat terhubung.'),
      );
      await tester.pump();
      expect(find.text('Tidak dapat terhubung.'), findsOneWidget);
      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      api.responses.last.complete(
        const ChatReply(reply: 'Jawaban uji dari layanan.'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Jawaban uji dari layanan.'), findsOneWidget);
      await tester.tap(find.text('Chat Baru'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.messages, isEmpty);
      expect(
        find.text(
          'Halo! Saya Pendekar Gendut, pelayan virtual Toko H Haris. Ada yang bisa saya bantu?',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Shift Enter inserts newline and Enter submits', (tester) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    await tester.pumpWidget(MyApp(controller: controller));
    await tester.enterText(find.byType(TextField), 'Halo');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(api.requests, isEmpty);
    // Hardware text insertion is platform-owned; assert our shortcut allows it.
    await tester.enterText(find.byType(TextField), 'Halo\nQRIS?');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(api.requests.single.message, 'Halo\nQRIS?');
    api.responses.single.complete(const ChatReply(reply: 'Bisa.'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('mobile keyboard inset leaves composer accessible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 330);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.getBottomRight(find.byType(TextField)).dy, lessThan(514));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('long response auto-scrolls to its end', (tester) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    await tester.pumpWidget(MyApp(controller: controller));
    final pending = controller.sendMessage('Informasi produk');
    await tester.pump(const Duration(milliseconds: 400));
    api.responses.single.complete(
      ChatReply(
        reply: List.filled(
          80,
          '**Informasi** uji produk dari layanan.',
        ).join('\n\n'),
        responseTimeMs: 1200,
      ),
    );
    await pending;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      controller.scrollController.position.pixels,
      closeTo(
        controller.scrollController.position.axisDirection == AxisDirection.up
            ? controller.scrollController.position.minScrollExtent
            : controller.scrollController.position.maxScrollExtent,
        1,
      ),
    );
    expect(find.text('Waktu respons: 1.2 detik'), findsOneWidget);
    expect(
      tester.getBottomRight(find.text('Waktu respons: 1.2 detik')).dy,
      lessThan(tester.getTopLeft(find.byType(TextField)).dy),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('large text remains within mobile layout constraints', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('rapid new chat and send cannot share two scroll positions', (
    tester,
  ) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    await tester.pumpWidget(MyApp(controller: controller));
    final old = controller.sendMessage('Lama');
    await tester.pump(const Duration(milliseconds: 400));
    controller.newChat();
    await tester.pump(const Duration(milliseconds: 16));
    final next = controller.sendMessage('Baru');
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.takeException(), isNull);
    expect(controller.scrollController.positions, hasLength(1));
    api.responses[0].complete(const ChatReply(reply: 'Lama'));
    api.responses[1].complete(const ChatReply(reply: 'Baru'));
    await old;
    await next;
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('landscape keyboard leaves multiline composer usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byType(TextField),
      'Baris satu\nBaris dua\nBaris tiga\nBaris empat',
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(tester.getBottomRight(find.byType(TextField)).dy, lessThan(190));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Enter does not submit text while IME composition is active', (
    tester,
  ) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    await tester.pumpWidget(MyApp(controller: controller));
    await tester.tap(find.byType(TextField));
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'Halo',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 0, end: 4),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(api.requests, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('latest reply stays visible when mobile keyboard appears', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final api = ControlledApi();
    final controller = ChatController(api: api);
    await tester.pumpWidget(MyApp(controller: controller));
    final pending = controller.sendMessage('Informasi');
    await tester.pump(const Duration(milliseconds: 400));
    api.responses.last.complete(
      ChatReply(reply: List.filled(40, 'Informasi dari layanan.').join('\n')),
    );
    await pending;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    tester.view.viewInsets = const FakeViewPadding(bottom: 330);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final lastBubble = find.byType(ChatBubble).last;
    expect(
      tester.getBottomRight(lastBubble).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(TextField)).dy),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('long conversations only mount nearby message bubbles', (
    tester,
  ) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    for (var i = 0; i < 50; i++) {
      final pending = controller.sendMessage('Pertanyaan $i');
      api.responses.last.complete(ChatReply(reply: 'Jawaban $i'));
      await pending;
    }
    await tester.pumpWidget(MyApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ChatBubble).evaluate().length, lessThan(30));
    expect(controller.messages, hasLength(100));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('failed message edit button restores the draft', (tester) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    await tester.pumpWidget(MyApp(controller: controller));
    final greeting = controller.sendMessage('Halo');
    await tester.pump(const Duration(milliseconds: 400));
    api.responses.last.complete(const ChatReply(reply: 'Halo kembali'));
    await greeting;
    await tester.pump(const Duration(milliseconds: 400));
    final pending = controller.sendMessage('Pesan keliru');
    await tester.pump(const Duration(milliseconds: 400));
    api.responses.last.completeError(
      const ChatApiException('Pesan tidak valid'),
    );
    await pending;
    await tester.pump();
    await tester.tap(find.text('Ubah pesan'));
    await tester.pump();
    expect(controller.inputController.text, 'Pesan keliru');
    expect(controller.messages, hasLength(2));
    expect(find.text('Halo kembali'), findsOneWidget);
    expect(find.text('Pesan tidak valid'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('reply arrival preserves manual reading position', (
    tester,
  ) async {
    final api = ControlledApi();
    final controller = ChatController(api: api);
    for (var i = 0; i < 15; i++) {
      final pending = controller.sendMessage('Pertanyaan $i');
      api.responses.last.complete(ChatReply(reply: 'Jawaban $i'));
      await pending;
    }
    await tester.pumpWidget(MyApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 400));
    final pending = controller.sendMessage('Pertanyaan terbaru');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 450));
    await tester.pump(const Duration(seconds: 1));
    expect(controller.scrollController.offset, greaterThan(300));
    final anchor = find.text('Jawaban 12');
    expect(anchor, findsOneWidget);
    final anchorY = tester.getTopLeft(anchor).dy;
    api.responses.last.complete(
      ChatReply(
        reply: List.filled(30, '- Jawaban terbaru yang panjang.').join('\n'),
      ),
    );
    await pending;
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(tester.getTopLeft(anchor).dy, closeTo(anchorY, 3));
    expect(tester.takeException(), isNull);
    controller.scrollToLatest();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.scrollController.offset, 0);
    expect(find.text('Jawaban terbaru yang panjang.'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });
}
