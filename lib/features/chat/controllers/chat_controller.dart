import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/api_config.dart';
import '../models/chat_message.dart';
import '../services/chat_api_service.dart';

class ChatController extends GetxController {
  ChatController({ChatApiService? api}) : _api = api ?? ChatApiService();

  final ChatApiService _api;
  final inputController = TextEditingController();
  final scrollController = ScrollController();
  final inputFocus = FocusNode();
  final _messages = <ChatMessage>[];
  UnmodifiableListView<ChatMessage> get messages =>
      UnmodifiableListView(_messages);

  bool isLoading = false;
  String? errorMessage;
  int conversation = 0;
  CancelToken? _cancelToken;
  bool _closed = false;
  int _scrollRequest = 0;

  bool get canCompose => !isLoading && errorMessage == null;
  String get conversationTitle =>
      _messages.isEmpty ? 'Percakapan Baru' : _messages.first.content;

  Future<void> sendMessage([String? text]) async {
    final message = (text ?? inputController.text).trim();
    if (message.isEmpty || !canCompose || _closed) return;
    _messages.add(
      ChatMessage(
        role: ChatRole.user,
        content: message,
        status: MessageStatus.pending,
      ),
    );
    inputController.clear();
    await _request();
  }

  Future<void> retry() async {
    if (isLoading || errorMessage == null || _messages.isEmpty || _closed) {
      return;
    }
    _messages[_messages.length - 1] = _messages.last.withStatus(
      MessageStatus.pending,
    );
    await _request();
  }

  void editFailedMessage() {
    if (_closed || isLoading || errorMessage == null || _messages.isEmpty) {
      return;
    }
    final failed = _messages.last;
    if (failed.status != MessageStatus.failed) return;
    _messages.removeLast();
    inputController.value = TextEditingValue(
      text: failed.content,
      selection: TextSelection.collapsed(offset: failed.content.length),
    );
    errorMessage = null;
    _refresh();
    inputFocus.requestFocus();
  }

  Future<void> _request() async {
    final generation = conversation;
    final token = CancelToken();
    _cancelToken = token;
    isLoading = true;
    errorMessage = null;
    _refresh();
    final history = _messages
        .where((message) => message.status == MessageStatus.delivered)
        .toList();
    final recentHistory = history.length > ApiConfig.historyLimit
        ? history.sublist(history.length - ApiConfig.historyLimit)
        : history;
    try {
      final reply = await _api.sendMessage(
        message: _messages.last.content,
        history: recentHistory,
        cancelToken: token,
      );
      if (_closed || generation != conversation) return;
      _messages[_messages.length - 1] = _messages.last.withStatus(
        MessageStatus.delivered,
      );
      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply.reply,
          responseTimeMs: reply.responseTimeMs,
        ),
      );
    } catch (error) {
      if (_closed || generation != conversation || token.isCancelled) return;
      _messages[_messages.length - 1] = _messages.last.withStatus(
        MessageStatus.failed,
      );
      errorMessage = error is ChatApiException
          ? error.message
          : 'Terjadi kendala saat mengirim pesan. Silakan coba lagi.';
    } finally {
      if (!_closed && generation == conversation) {
        isLoading = false;
        _cancelToken = null;
        _refresh();
        inputFocus.requestFocus();
      }
    }
  }

  void newChat() {
    conversation++;
    _cancelToken?.cancel('Chat baru');
    _cancelToken = null;
    _messages.clear();
    inputController.clear();
    errorMessage = null;
    isLoading = false;
    _refresh();
    inputFocus.requestFocus();
  }

  void _refresh() {
    update();
    scrollToLatest(onlyIfNearBottom: true);
  }

  void cancelAutoScroll() => _scrollRequest++;

  void scrollToLatest({bool onlyIfNearBottom = false}) {
    final request = ++_scrollRequest;
    final generation = conversation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_closed ||
          request != _scrollRequest ||
          generation != conversation ||
          !scrollController.hasClients) {
        return;
      }
      final position = scrollController.position;
      final latest = position.axisDirection == AxisDirection.up
          ? position.minScrollExtent
          : position.maxScrollExtent;
      // Follow the conversation only while the reader is near the newest reply.
      if (onlyIfNearBottom && (position.pixels - latest).abs() > 80) return;

      void settleAtLatest(Duration _) {
        if (_closed ||
            request != _scrollRequest ||
            generation != conversation ||
            !scrollController.hasClients ||
            scrollController.position != position ||
            position.isScrollingNotifier.value) {
          return;
        }
        final target = position.axisDirection == AxisDirection.up
            ? position.minScrollExtent
            : position.maxScrollExtent;
        if ((position.pixels - target).abs() < .5) return;
        position.jumpTo(target);
        // Lazy layout can correct the offset after measuring a tall bubble.
        WidgetsBinding.instance.addPostFrameCallback(settleAtLatest);
      }

      position.jumpTo(latest);
      WidgetsBinding.instance.addPostFrameCallback(settleAtLatest);
    });
    // Sidebar navigation may not otherwise schedule a frame.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void onClose() {
    _closed = true;
    _cancelToken?.cancel('Halaman ditutup');
    _api.close();
    inputController.dispose();
    scrollController.dispose();
    inputFocus.dispose();
    super.onClose();
  }
}
