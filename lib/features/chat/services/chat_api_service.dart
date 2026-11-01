import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/api_config.dart';
import '../models/chat_message.dart';

class ChatApiException implements Exception {
  const ChatApiException(this.message, {this.requiresNewConversation = false});
  final String message;
  final bool requiresNewConversation;
}

class ChatApiService {
  ChatApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = ApiConfig.connectTimeout
      ..sendTimeout = ApiConfig.sendTimeout
      ..receiveTimeout = ApiConfig.receiveTimeout
      ..contentType = Headers.jsonContentType;
  }

  final Dio _dio;

  static const _shoppingRecovery = ChatApiException(
    'Daftar belanja tidak dapat dilanjutkan atau sudah kedaluwarsa. '
    'Pilih Percakapan Baru, lalu sebutkan kembali produk dan anggaran Anda.',
    requiresNewConversation: true,
  );

  Future<ChatReply> sendMessage({
    required String message,
    required List<ChatMessage> history,
    required CancelToken cancelToken,
    String? shoppingContext,
  }) async {
    if (kDebugMode) {
      debugPrint('[Chat API] Base URL: ${_dio.options.baseUrl}');
      debugPrint('[Chat API] Endpoint: POST /api/chat');
    }
    try {
      final response = await _dio.post<Object?>(
        '/api/chat',
        data: {
          'message': message,
          'history': _serializeHistory(history),
          'shopping_context': ?shoppingContext,
        },
        cancelToken: cancelToken,
      );
      if (kDebugMode) {
        debugPrint('[Chat API] URL: ${response.requestOptions.uri}');
        debugPrint('[Chat API] Status code: ${response.statusCode}');
      }
      final reply = ChatReply.fromJson(response.data);
      if (shoppingContext != null && reply.shoppingContext == null) {
        throw _shoppingRecovery;
      }
      return reply;
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint('[Chat API] URL: ${error.requestOptions.uri}');
        debugPrint(
          '[Chat API] Status code: ${error.response?.statusCode ?? "Tidak ada respons HTTP"}',
        );
        debugPrint('[Chat API] Jenis error: ${error.type.name}');
      }
      if (CancelToken.isCancel(error)) rethrow;
      if (shoppingContext != null && error.response?.statusCode == 400) {
        throw _shoppingRecovery;
      }
      throw ChatApiException(_errorMessage(error));
    } on FormatException {
      if (kDebugMode) {
        debugPrint('[Chat API] Format response tidak valid.');
      }
      if (shoppingContext != null) throw _shoppingRecovery;
      throw const ChatApiException(
        'Jawaban dari layanan belum dapat dibaca. Silakan coba lagi.',
      );
    }
  }

  List<Map<String, String>> _serializeHistory(List<ChatMessage> history) {
    final turns = <Map<String, String>>[];
    for (var i = 0; i + 1 < history.length; i++) {
      final user = history[i];
      final reply = history[i + 1];
      if (user.role != ChatRole.user ||
          reply.role != ChatRole.assistant ||
          user.status != MessageStatus.delivered ||
          reply.status != MessageStatus.delivered ||
          user.content.trim().isEmpty ||
          reply.content.trim().isEmpty) {
        continue;
      }
      turns.addAll([user.toHistoryJson(), reply.toHistoryJson()]);
      i++;
    }
    return turns;
  }

  String _errorMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Layanan membutuhkan waktu lebih lama. Silakan coba lagi.';
    }
    return switch (error.response?.statusCode ?? 0) {
      422 =>
        'Pesan belum dapat diproses. Pilih Ubah pesan, lalu kirim kembali.',
      429 => 'Layanan sedang sibuk. Tunggu sebentar, lalu coba lagi.',
      >= 500 => 'Layanan AI sedang mengalami gangguan. Silakan coba lagi.',
      0 => 'Tidak dapat terhubung ke layanan. Periksa koneksi dan coba lagi.',
      _ => 'Permintaan belum berhasil. Silakan coba lagi.',
    };
  }

  void close() => _dio.close(force: true);
}
