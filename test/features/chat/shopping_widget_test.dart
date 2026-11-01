import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/models/chat_message.dart';
import 'package:ai_chatbot/features/chat/services/chat_api_service.dart';
import 'package:ai_chatbot/features/chat/widgets/chat_bubble.dart';
import 'package:ai_chatbot/features/chat/widgets/chat_error_message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_chat_app.dart';
import 'chat_api_service_test.dart' show TestAdapter;
import 'chat_controller_test.dart' show ControlledApi;
import 'shopping_service_test.dart' show shoppingReply;

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'shopping chat, quantity, removal and new conversation at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final adapter = TestAdapter(
          shoppingReply('2 kaleng. Total Rp21.600.', 'PRIVATE.signed-add'),
        );
        final controller = ChatController(
          api: ChatApiService(dio: Dio()..httpClientAdapter = adapter),
        );
        await pumpChatApp(tester, controller: controller);

        Future<void> submit(String message) async {
          await tester.enterText(find.byType(TextField), message);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
        }

        await submit('Tambahkan 2 Bear Brand, anggaran Rp50.000');
        expect(find.text('2 kaleng. Total Rp21.600.'), findsOneWidget);
        expect(
          (adapter.requestBodies.single as Map).containsKey('shopping_context'),
          isFalse,
        );
        adapter.body = shoppingReply(
          '3 kaleng. Total Rp32.400. Sisa Rp17.600.',
          'PRIVATE.signed-quantity',
        );
        await submit('Jadikan tiga saja');
        expect(
          find.text('3 kaleng. Total Rp32.400. Sisa Rp17.600.'),
          findsOneWidget,
        );
        expect(
          (adapter.requestBodies.last as Map)['shopping_context'],
          'PRIVATE.signed-add',
        );
        adapter.body = shoppingReply(
          'Daftar kosong. Total Rp0.',
          'PRIVATE.signed-remove',
        );
        await submit('Hapus Bear Brand');
        expect(find.text('Daftar kosong. Total Rp0.'), findsOneWidget);
        expect(
          (adapter.requestBodies.last as Map)['shopping_context'],
          'PRIVATE.signed-quantity',
        );
        expect(find.textContaining('PRIVATE'), findsNothing);
        expect(find.textContaining('shopping_context'), findsNothing);

        if (size.width < 760) {
          await tester.tap(find.byTooltip('Percakapan Baru'));
        } else {
          await tester.tap(find.text('Percakapan Baru').first);
        }
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(ChatBubble), findsNothing);
        adapter.body = {
          'success': true,
          'reply': 'Toko di Condet.',
          'response_time_ms': 12,
        };
        await submit('Di mana tokonya?');
        expect(adapter.requestBodies.last, {
          'message': 'Di mana tokonya?',
          'history': [],
        });
        expect(find.text('Toko di Condet.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  for (final reason in ['expired', 'invalid']) {
    testWidgets('$reason context offers reset instead of replay', (
      tester,
    ) async {
      final adapter = TestAdapter(
        shoppingReply('Daftar belanja.', 'PRIVATE.expired'),
      );
      final controller = ChatController(
        api: ChatApiService(dio: Dio()..httpClientAdapter = adapter),
      );
      await pumpChatApp(tester, controller: controller);
      await tester.runAsync(
        () => controller.sendMessage('Tambahkan Bear Brand'),
      );
      await tester.pumpAndSettle();
      adapter.statusCode = 400;
      adapter.body = {'detail': 'PRIVATE.$reason'};
      await tester.runAsync(() => controller.sendMessage('Jadikan tiga saja'));
      await tester.pumpAndSettle();
      final panel = find.byType(ChatErrorMessage);
      expect(panel, findsOneWidget);
      expect(
        find.descendant(of: panel, matching: find.text('Coba Lagi')),
        findsNothing,
      );
      expect(
        find.descendant(of: panel, matching: find.text('Ubah pesan')),
        findsNothing,
      );
      expect(find.textContaining('PRIVATE'), findsNothing);
      await tester.tap(
        find.descendant(of: panel, matching: find.text('Percakapan Baru')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ChatErrorMessage), findsNothing);
      adapter.statusCode = 200;
      adapter.body = shoppingReply('Daftar baru.', 'PRIVATE.new');
      await tester.runAsync(() => controller.sendMessage('Tambahkan Aqua'));
      expect(
        (adapter.requestBodies.last as Map).containsKey('shopping_context'),
        isFalse,
      );
      await tester.pumpAndSettle();
      expect(find.text('Daftar baru.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('network failure keeps shopping context and allows retry', (
    tester,
  ) async {
    final adapter = TestAdapter(
      shoppingReply('Daftar belanja.', 'PRIVATE.accepted'),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final controller = ChatController(api: ChatApiService(dio: dio));
    await pumpChatApp(tester, controller: controller);
    await tester.runAsync(() => controller.sendMessage('Tambahkan Bear Brand'));
    await tester.pumpAndSettle();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          );
        },
      ),
    );
    await tester.runAsync(() => controller.sendMessage('Jadikan tiga saja'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Periksa koneksi'), findsOneWidget);
    dio.interceptors.clear();
    adapter.body = shoppingReply(
      '3 kaleng. Total Rp32.400.',
      'PRIVATE.updated',
    );
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(
      (adapter.requestBodies.last as Map)['shopping_context'],
      'PRIVATE.accepted',
    );
    expect(find.text('3 kaleng. Total Rp32.400.'), findsOneWidget);
    expect(find.byType(ChatErrorMessage), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'duplicate submissions and stale shopping replies cannot change the next conversation',
    (tester) async {
      final api = ControlledApi();
      final controller = ChatController(api: api);
      await pumpChatApp(tester, controller: controller);
      await tester.enterText(find.byType(TextField), 'Tambahkan Bear Brand');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.runAsync(
        () => controller.sendMessage('Tambahkan Bear Brand'),
      );
      await tester.pump();
      expect(api.requests, hasLength(1));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      controller.newChat();
      final current = controller.sendMessage('Tambahkan Aqua');
      api.responses[1].complete(
        const ChatReply(
          reply: 'Daftar Aqua.',
          shoppingContext: 'PRIVATE.current',
        ),
      );
      await current;
      api.responses[0].complete(
        const ChatReply(
          reply: 'Daftar lama.',
          shoppingContext: 'PRIVATE.stale',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daftar lama.'), findsNothing);
      expect(find.text('Daftar Aqua.'), findsOneWidget);
      final followup = controller.sendMessage('Jadikan dua saja');
      expect(api.requests.last.shoppingContext, 'PRIVATE.current');
      api.responses.last.complete(
        const ChatReply(reply: '2 Aqua.', shoppingContext: 'PRIVATE.next'),
      );
      await followup;
      await tester.pumpAndSettle();
      expect(find.textContaining('PRIVATE'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
