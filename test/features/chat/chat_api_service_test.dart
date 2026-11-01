import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_chatbot/core/config/api_config.dart';
import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/features/chat/models/chat_message.dart';
import 'package:ai_chatbot/features/chat/services/chat_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.body, {this.statusCode = 200});
  final Object body;
  int statusCode;
  RequestOptions? request;
  final requestBodies = <Object?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final bytes = await requestStream!.expand((chunk) => chunk).toList();
    requestBodies.add(jsonDecode(utf8.decode(bytes)));
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('parses successful response and duration', () {
    final reply = ChatReply.fromJson({
      'success': true,
      'reply': 'Tersedia.',
      'response_time_ms': 5358,
    });
    expect(reply.reply, 'Tersedia.');
    expect(reply.responseTimeMs, 5358);
  });

  test('rejects invalid or unsuccessful API payloads', () {
    for (final payload in <Object?>[
      null,
      [],
      {},
      {'success': false, 'reply': 'x'},
      {'success': true, 'reply': ' '},
      {'success': true, 'reply': 2},
    ]) {
      expect(() => ChatReply.fromJson(payload), throwsFormatException);
    }
  });

  test('Dio posts the exact FastAPI role/text history contract', () async {
    final adapter = TestAdapter({'success': true, 'reply': 'Bisa.'});
    final dio = Dio()..httpClientAdapter = adapter;
    final service = ChatApiService(dio: dio);
    final result = await service.sendMessage(
      message: 'QRIS?',
      history: [
        const ChatMessage(role: ChatRole.user, content: 'Halo'),
        const ChatMessage(role: ChatRole.assistant, content: 'Halo kembali.'),
      ],
      cancelToken: CancelToken(),
    );
    expect(result.reply, 'Bisa.');
    expect(adapter.request?.path, '/api/chat');
    expect(adapter.request?.uri.toString(), '${ApiConfig.baseUrl}/api/chat');
    expect(adapter.requestBodies.single, {
      'message': 'QRIS?',
      'history': [
        {'role': 'user', 'text': 'Halo'},
        {'role': 'model', 'text': 'Halo kembali.'},
      ],
    });
    service.close();
  });

  test('history contains only complete nonempty delivered turns', () async {
    final adapter = TestAdapter({'success': true, 'reply': 'Bisa.'});
    final service = ChatApiService(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(service.close);
    await service.sendMessage(
      message: 'Sekarang',
      history: [
        const ChatMessage(role: ChatRole.assistant, content: 'Tanpa user'),
        const ChatMessage(
          role: ChatRole.user,
          content: 'Gagal',
          status: MessageStatus.failed,
        ),
        const ChatMessage(
          role: ChatRole.assistant,
          content: 'Error',
          status: MessageStatus.failed,
        ),
        const ChatMessage(
          role: ChatRole.user,
          content: 'Menunggu',
          status: MessageStatus.pending,
        ),
        const ChatMessage(
          role: ChatRole.assistant,
          content: 'Loading',
          status: MessageStatus.pending,
        ),
        const ChatMessage(role: ChatRole.user, content: ' '),
        const ChatMessage(
          role: ChatRole.assistant,
          content: 'Tanpa pertanyaan',
        ),
        const ChatMessage(role: ChatRole.user, content: 'Jawaban kosong'),
        const ChatMessage(role: ChatRole.assistant, content: '\n'),
        const ChatMessage(role: ChatRole.user, content: 'Jawaban gagal'),
        const ChatMessage(
          role: ChatRole.assistant,
          content: 'Error',
          status: MessageStatus.failed,
        ),
        const ChatMessage(role: ChatRole.user, content: 'Jawaban tertunda'),
        const ChatMessage(
          role: ChatRole.assistant,
          content: 'Loading',
          status: MessageStatus.pending,
        ),
        const ChatMessage(role: ChatRole.user, content: 'Halo'),
        const ChatMessage(role: ChatRole.assistant, content: 'Halo kembali.'),
        const ChatMessage(role: ChatRole.user, content: 'Belum dijawab'),
      ],
      cancelToken: CancelToken(),
    );
    expect(adapter.requestBodies.single, {
      'message': 'Sekarang',
      'history': [
        {'role': 'user', 'text': 'Halo'},
        {'role': 'model', 'text': 'Halo kembali.'},
      ],
    });
  });

  test('follow-up, repeated retry and new chat send correct JSON', () async {
    final adapter = TestAdapter({'success': true, 'reply': 'Rp75.000.'});
    final controller = ChatController(
      api: ChatApiService(dio: Dio()..httpClientAdapter = adapter),
    );
    addTearDown(controller.onClose);
    await controller.sendMessage('Harga Ramos?');
    expect(adapter.requestBodies.single, {
      'message': 'Harga Ramos?',
      'history': [],
    });

    adapter.statusCode = 502;
    await controller.sendMessage('Untuk 5 kg?');
    const followUp = {
      'message': 'Untuk 5 kg?',
      'history': [
        {'role': 'user', 'text': 'Harga Ramos?'},
        {'role': 'model', 'text': 'Rp75.000.'},
      ],
    };
    expect(adapter.requestBodies[1], followUp);
    await controller.retry();
    expect(adapter.requestBodies[2], followUp);
    expect(controller.messages, hasLength(3));
    expect(controller.messages.last.status, MessageStatus.failed);

    adapter.statusCode = 200;
    await controller.retry();
    expect(adapter.requestBodies[3], followUp);
    expect(controller.messages, hasLength(4));
    await controller.sendMessage('Tersedia?');
    expect(adapter.requestBodies[4], {
      'message': 'Tersedia?',
      'history': [
        {'role': 'user', 'text': 'Harga Ramos?'},
        {'role': 'model', 'text': 'Rp75.000.'},
        {'role': 'user', 'text': 'Untuk 5 kg?'},
        {'role': 'model', 'text': 'Rp75.000.'},
      ],
    });

    controller.newChat();
    await controller.sendMessage('Halo');
    expect(adapter.requestBodies.last, {'message': 'Halo', 'history': []});
  });

  test(
    'HTTP errors and unexpected payloads become safe Indonesian errors',
    () async {
      for (final status in [200, 422, 429, 500, 502]) {
        final dio = Dio()
          ..httpClientAdapter = TestAdapter({
            'secret': 'sensitive internal detail',
          }, statusCode: status);
        final service = ChatApiService(dio: dio);
        await expectLater(
          service.sendMessage(
            message: 'Halo',
            history: [],
            cancelToken: CancelToken(),
          ),
          throwsA(
            isA<ChatApiException>().having(
              (e) => e.message.contains('sensitive'),
              'no internal error leaked',
              isFalse,
            ),
          ),
        );
        service.close();
      }
    },
  );
  test('debug logs exclude successful and failed response payloads', () async {
    const marker = 'DUMMY_PRIVATE_PAYLOAD';
    final logs = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = originalDebugPrint);
    for (final status in [200, 502]) {
      final service = ChatApiService(
        dio: Dio()
          ..httpClientAdapter = TestAdapter({
            'success': true,
            'reply': marker,
          }, statusCode: status),
      );
      try {
        final request = service.sendMessage(
          message: 'Halo',
          history: [],
          cancelToken: CancelToken(),
        );
        if (status == 200) {
          await request;
        } else {
          await expectLater(request, throwsA(isA<ChatApiException>()));
        }
      } finally {
        service.close();
      }
    }
    expect(logs.join('\n'), isNot(contains(marker)));
    expect(logs.join('\n'), contains('Status code: 502'));
  });

  test('all client timeout types return safe recovery guidance', () async {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.reject(
              DioException(
                requestOptions: options,
                type: type,
                error: 'DUMMY_PRIVATE_PAYLOAD',
              ),
            ),
          ),
        );
      final service = ChatApiService(dio: dio);
      try {
        await expectLater(
          service.sendMessage(
            message: 'Halo',
            history: [],
            cancelToken: CancelToken(),
          ),
          throwsA(
            isA<ChatApiException>().having(
              (error) => error.message,
              'safe timeout guidance',
              'Layanan membutuhkan waktu lebih lama. Silakan coba lagi.',
            ),
          ),
        );
      } finally {
        service.close();
      }
    }
  });
}
