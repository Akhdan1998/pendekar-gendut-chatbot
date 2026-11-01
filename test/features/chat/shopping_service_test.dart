import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/models/chat_message.dart';
import 'package:ai_chatbot/features/chat/services/chat_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_api_service_test.dart' show TestAdapter;

Map<String, Object?> shoppingReply(String reply, Object? context) => {
  'success': true,
  'reply': reply,
  'response_time_ms': 12,
  'shopping_context': context,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'shopping operations round-trip opaque context and server totals',
    () async {
      final adapter = TestAdapter(
        shoppingReply('2 kaleng. Total Rp21.600.', ' signed.add '),
      );
      final controller = ChatController(
        api: ChatApiService(dio: Dio()..httpClientAdapter = adapter),
      );
      addTearDown(controller.onClose);

      await controller.sendMessage('Tambahkan 2 Bear Brand, anggaran Rp50.000');
      expect(adapter.requestBodies.single, {
        'message': 'Tambahkan 2 Bear Brand, anggaran Rp50.000',
        'history': [],
      });
      expect(controller.messages.last.content, '2 kaleng. Total Rp21.600.');

      for (final step in [
        (
          message: 'Jadikan tiga saja',
          sent: ' signed.add ',
          next: 'signed.quantity',
          reply: '3 kaleng. Total Rp32.400. Sisa Rp17.600.',
        ),
        (
          message: 'Di mana tokonya?',
          sent: 'signed.quantity',
          next: 'signed.quantity',
          reply: 'Alamat toko di Condet.',
        ),
        (
          message: 'Hapus Bear Brand',
          sent: 'signed.quantity',
          next: 'signed.remove',
          reply: 'Daftar kosong. Total Rp0.',
        ),
        (
          message: 'Sisa anggaran berapa?',
          sent: 'signed.remove',
          next: 'signed.show',
          reply: 'Sisa Rp50.000.',
        ),
      ]) {
        adapter.body = shoppingReply(step.reply, step.next);
        await controller.sendMessage(step.message);
        final body = adapter.requestBodies.last as Map;
        expect(
          body.keys,
          unorderedEquals(['message', 'history', 'shopping_context']),
        );
        expect(body['message'], step.message);
        expect(body['shopping_context'], step.sent);
        expect(body['history'], isNotEmpty);
        expect(controller.messages.last.content, step.reply);
      }
      controller.newChat();
      adapter.body = {
        'success': true,
        'reply': 'Halo.',
        'response_time_ms': 12,
      };
      await controller.sendMessage('Halo');
      expect(adapter.requestBodies.last, {'message': 'Halo', 'history': []});
      expect(controller.messages.last.content, 'Halo.');
    },
  );

  test('optional context stays opaque and malformed values are rejected', () {
    const token = ' opaque.signed-token ';
    expect(
      ChatReply.fromJson(shoppingReply('Daftar.', token)).reply,
      'Daftar.',
    );
    expect(ChatReply.fromJson(shoppingReply('Halo.', null)).reply, 'Halo.');
    for (final context in <Object>['', ' ' * 2, 'x' * 16385, 12, [], {}]) {
      expect(
        () => ChatReply.fromJson(shoppingReply('Daftar.', context)),
        throwsFormatException,
      );
    }
  });

  test('rejected context HTTP 400 requires a new conversation', () async {
    final adapter = TestAdapter(shoppingReply('Daftar.', 'expired.token'));
    final controller = ChatController(
      api: ChatApiService(dio: Dio()..httpClientAdapter = adapter),
    );
    addTearDown(controller.onClose);
    await controller.sendMessage('Tambahkan Bear Brand');
    adapter.statusCode = 400;
    adapter.body = {'detail': 'PRIVATE_CONTEXT_AND_SCHEMA'};
    await controller.sendMessage('Jadikan tiga saja');
    expect(controller.errorMessage, contains('Percakapan Baru'));
    expect(controller.errorMessage, isNot(contains('PRIVATE')));
    await controller.retry();
    controller.editFailedMessage();
    await controller.sendMessage('Hapus semuanya');
    expect(adapter.requestBodies, hasLength(2));
    controller.newChat();
    adapter.statusCode = 200;
    adapter.body = shoppingReply('Daftar baru.', 'fresh.token');
    await controller.sendMessage('Tambahkan Aqua');
    expect(
      (adapter.requestBodies.last as Map).containsKey('shopping_context'),
      isFalse,
    );
  });

  test(
    'message validation failure preserves the shopping list when edited',
    () async {
      final adapter = TestAdapter(shoppingReply('Daftar.', 'previous.token'));
      final controller = ChatController(
        api: ChatApiService(dio: Dio()..httpClientAdapter = adapter),
      );
      addTearDown(controller.onClose);
      await controller.sendMessage('Tambahkan Bear Brand');
      adapter.statusCode = 422;
      adapter.body = {
        'detail': [
          {
            'type': 'string_too_long',
            'loc': ['body', 'message'],
            'msg': 'String should have at most 2000 characters',
          },
        ],
      };
      await controller.sendMessage('x' * 2001);
      expect(controller.errorMessage, contains('Ubah pesan'));
      controller.editFailedMessage();
      expect(controller.inputController.text, 'x' * 2001);
      adapter.statusCode = 200;
      adapter.body = shoppingReply(
        '3 kaleng. Total Rp32.400.',
        'updated.token',
      );
      await controller.sendMessage('Jadikan tiga saja');
      expect(
        (adapter.requestBodies.last as Map)['shopping_context'],
        'previous.token',
      );
      expect(controller.errorMessage, isNull);
    },
  );

  for (final body in [
    {'success': true, 'reply': 'Daftar.', 'response_time_ms': 12},
    shoppingReply('Daftar.', null),
    shoppingReply('Daftar.', 99),
    shoppingReply('Daftar.', ''),
  ]) {
    test(
      'missing or malformed follow-up context cannot silently lose a list: $body',
      () async {
        final adapter = TestAdapter(shoppingReply('Daftar.', 'previous.token'));
        final controller = ChatController(
          api: ChatApiService(dio: Dio()..httpClientAdapter = adapter),
        );
        addTearDown(controller.onClose);
        await controller.sendMessage('Tambahkan Bear Brand');
        adapter.body = body;
        await controller.sendMessage('Jadikan tiga saja');
        expect(controller.messages.last.status, MessageStatus.failed);
      },
    );
  }

  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
  ]) {
    test('$type keeps the last accepted context for explicit retry', () async {
      final adapter = TestAdapter(shoppingReply('Daftar.', 'previous.token'));
      final dio = Dio()..httpClientAdapter = adapter;
      final controller = ChatController(api: ChatApiService(dio: dio));
      addTearDown(controller.onClose);
      await controller.sendMessage('Tambahkan Bear Brand');
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect((options.data as Map)['shopping_context'], 'previous.token');
            handler.reject(DioException(requestOptions: options, type: type));
          },
        ),
      );
      await controller.sendMessage('Jadikan tiga saja');
      expect(controller.errorMessage, isNotNull);
      dio.interceptors.clear();
      adapter.body = shoppingReply(
        '3 kaleng. Total Rp32.400.',
        'updated.token',
      );
      await controller.retry();
      expect(
        (adapter.requestBodies.last as Map)['shopping_context'],
        'previous.token',
      );
      expect(controller.messages, hasLength(4));
      expect(controller.errorMessage, isNull);
    });
  }
}
