import 'dart:async';

import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/models/chat_message.dart';
import 'package:ai_chatbot/features/chat/services/chat_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledApi extends ChatApiService {
  final requests = <({String message, List<ChatMessage> history})>[];
  final responses = <Completer<ChatReply>>[];

  @override
  Future<ChatReply> sendMessage({
    required String message,
    required List<ChatMessage> history,
    required CancelToken cancelToken,
  }) {
    requests.add((message: message, history: List.of(history)));
    final completer = Completer<ChatReply>();
    responses.add(completer);
    return completer.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ControlledApi api;
  late ChatController controller;

  setUp(() {
    api = ControlledApi();
    controller = ChatController(api: api);
  });
  tearDown(() => controller.onClose());

  test('empty and whitespace input cannot start a request', () async {
    await controller.sendMessage(' \n ');
    expect(controller.messages, isEmpty);
    expect(api.requests, isEmpty);
    expect(controller.isLoading, isFalse);
  });

  test(
    'pending message appears immediately and duplicate send is ignored',
    () async {
      final pending = controller.sendMessage('  Jam buka?  ');
      expect(controller.messages.single.content, 'Jam buka?');
      expect(controller.isLoading, isTrue);
      await controller.sendMessage('Jam buka?');
      expect(api.requests, hasLength(1));
      api.responses.single.complete(
        const ChatReply(reply: '08:00–20:00 WIB', responseTimeMs: 12),
      );
      await pending;
      expect(controller.isLoading, isFalse);
      expect(controller.messages.last.role, ChatRole.assistant);
      expect(controller.messages.last.responseTimeMs, 12);
      expect(controller.errorMessage, isNull);
    },
  );

  test(
    'failure preserves input message and retry does not duplicate it',
    () async {
      final first = controller.sendMessage('Bisa QRIS?');
      api.responses[0].completeError(
        const ChatApiException('Tidak dapat terhubung.'),
      );
      await first;
      expect(controller.messages, hasLength(1));
      expect(controller.messages.single.status, MessageStatus.failed);
      expect(controller.errorMessage, 'Tidak dapat terhubung.');
      final retry = controller.retry();
      expect(api.requests[1].message, 'Bisa QRIS?');
      expect(api.requests[1].history, isEmpty);
      api.responses[1].complete(
        const ChatReply(reply: 'Bisa menggunakan QRIS.'),
      );
      await retry;
      expect(controller.messages, hasLength(2));
      expect(controller.messages.first.status, MessageStatus.delivered);
      expect(controller.errorMessage, isNull);
    },
  );

  test(
    'history uses the last ten completed messages and excludes current input',
    () async {
      for (var i = 0; i < 7; i++) {
        final pending = controller.sendMessage('Pertanyaan $i');
        api.responses[i].complete(ChatReply(reply: 'Jawaban $i'));
        await pending;
      }
      expect(api.requests.last.history, hasLength(10));
      expect(api.requests.last.history.first.content, 'Pertanyaan 1');
      expect(api.requests.last.history.last.content, 'Jawaban 5');
      expect(api.requests.last.history.first.toHistoryJson(), {
        'role': 'user',
        'text': 'Pertanyaan 1',
      });
      expect(api.requests.last.history.last.toHistoryJson()['role'], 'model');
    },
  );

  test(
    'new chat resets messages, draft, error and rejects a stale response',
    () async {
      final pending = controller.sendMessage('Pesan lama');
      controller.inputController.text = 'draf';
      controller.newChat();
      expect(controller.messages, isEmpty);
      expect(controller.inputController.text, isEmpty);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
      api.responses.single.complete(const ChatReply(reply: 'Jawaban lama'));
      await pending;
      expect(controller.messages, isEmpty);
    },
  );
  test('old request cannot finish a newer conversation request', () async {
    final old = controller.sendMessage('Lama');
    controller.newChat();
    final current = controller.sendMessage('Baru');
    api.responses[0].complete(const ChatReply(reply: 'Jawaban lama'));
    await old;
    expect(controller.isLoading, isTrue);
    expect(controller.messages.single.content, 'Baru');
    api.responses[1].complete(const ChatReply(reply: 'Jawaban baru'));
    await current;
    expect(controller.isLoading, isFalse);
    expect(controller.messages.last.content, 'Jawaban baru');
  });

  test('new chat clears failed state and permits the next request', () async {
    final failed = controller.sendMessage('Gagal');
    api.responses.single.completeError(StateError('internal detail'));
    await failed;
    expect(controller.errorMessage, isNot(contains('internal detail')));
    controller.newChat();
    expect(controller.errorMessage, isNull);
    expect(controller.canCompose, isTrue);
    final next = controller.sendMessage('Halo');
    expect(api.requests.last.history, isEmpty);
    api.responses.last.complete(const ChatReply(reply: 'Halo kembali.'));
    await next;
    expect(controller.messages, hasLength(2));
  });
  test(
    'failed message can be edited without clearing successful history',
    () async {
      final first = controller.sendMessage('Halo');
      api.responses.last.complete(const ChatReply(reply: 'Halo kembali'));
      await first;
      final failed = controller.sendMessage('Pertanyaan keliru');
      api.responses.last.completeError(
        const ChatApiException('Pesan tidak valid'),
      );
      await failed;
      controller.editFailedMessage();
      expect(controller.messages, hasLength(2));
      expect(controller.inputController.text, 'Pertanyaan keliru');
      expect(controller.canCompose, isTrue);
      expect(controller.errorMessage, isNull);
      final corrected = controller.sendMessage('Pertanyaan baru');
      expect(api.requests.last.history, hasLength(2));
      api.responses.last.complete(const ChatReply(reply: 'Jawaban baru'));
      await corrected;
      expect(controller.messages, hasLength(4));
      expect(controller.messages[2].content, 'Pertanyaan baru');
    },
  );
}
