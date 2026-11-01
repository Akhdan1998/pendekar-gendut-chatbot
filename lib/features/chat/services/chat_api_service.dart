import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/api_config.dart';
import '../models/chat_message.dart';

class ChatApiException implements Exception {
  const ChatApiException(this.message);
  final String message;
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

  Future<ChatReply> sendMessage({
    required String message,
    required List<ChatMessage> history,
    required CancelToken cancelToken,
  }) async {
    if (kDebugMode) {
      debugPrint('[Chat API] Base URL: ${_dio.options.baseUrl}');
      debugPrint('[Chat API] Endpoint: POST /api/chat');
    }
    try {
      final response = await _dio.post<Object?>(
        '/api/chat',
        data: {'message': message, 'history': _serializeHistory(history)},
        cancelToken: cancelToken,
      );
      if (kDebugMode) {
        debugPrint('[Chat API] URL: ${response.requestOptions.uri}');
        debugPrint('[Chat API] Status code: ${response.statusCode}');
      }
      return ChatReply.fromJson(response.data);
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint('[Chat API] URL: ${error.requestOptions.uri}');
        debugPrint(
          '[Chat API] Status code: ${error.response?.statusCode ?? "Tidak ada respons HTTP"}',
        );
        debugPrint('[Chat API] Jenis error: ${error.type.name}');
      }
      if (CancelToken.isCancel(error)) rethrow;
      throw ChatApiException(_errorMessage(error));
    } on FormatException {
      if (kDebugMode) {
        debugPrint('[Chat API] Format response tidak valid.');
      }
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
