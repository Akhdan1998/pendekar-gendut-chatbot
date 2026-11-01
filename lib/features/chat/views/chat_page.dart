import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_error_message.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/welcome_section.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.controller});
  final ChatController? controller;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final _controller = widget.controller ?? ChatController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    if (widget.controller == null) _controller.onClose();
    super.dispose();
  }

  void _newChat() {
    _scaffoldKey.currentState?.closeDrawer();
    _controller.newChat();
  }

  void _openConversation() {
    _scaffoldKey.currentState?.closeDrawer();
    _controller.scrollToLatest();
  }

  Widget _sidebar(ChatController controller) => ChatSidebar(
    title: controller.conversationTitle,
    hasMessages: controller.messages.isNotEmpty,
    onNewChat: _newChat,
    onConversation: _openConversation,
  );

  @override
  Widget build(BuildContext context) => GetBuilder<ChatController>(
    init: _controller,
    global: false,
    autoRemove: false,
    builder: (controller) => LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;
        final availableHeight =
            constraints.maxHeight - MediaQuery.viewInsetsOf(context).bottom;
        final compact =
            availableHeight < 360 * MediaQuery.textScalerOf(context).scale(1);
        final outerInset = isNarrow || availableHeight < 600 ? 0.0 : 24.0;
        final sidebarWidth = constraints.maxWidth >= 1200 ? 280.0 : 240.0;
        return Scaffold(
          key: _scaffoldKey,
          drawer: isNarrow
              ? Drawer(width: 290, child: _sidebar(controller))
              : null,
          drawerScrimColor: Colors.black54,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(outerInset),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1440,
                    maxHeight: 1000,
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(outerInset),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        if (!isNarrow) ...[
                          SizedBox(
                            width: sidebarWidth,
                            child: _sidebar(controller),
                          ),
                          const VerticalDivider(width: 1, thickness: 1),
                        ],
                        Expanded(
                          child: Column(
                            children: [
                              ChatHeader(
                                compact: compact,
                                onMenu: isNarrow
                                    ? () => _scaffoldKey.currentState
                                          ?.openDrawer()
                                    : null,
                                onNewChat: isNarrow ? _newChat : null,
                              ),
                              Expanded(
                                child: AnimatedSwitcher(
                                  // Keep one live scroll view during rapid session changes.
                                  layoutBuilder: (
                                    currentChild,
                                    previousChildren,
                                  ) => currentChild ?? const SizedBox.shrink(),
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 220),
                                  child: controller.messages.isEmpty
                                      ? _welcome(controller)
                                      : _conversation(controller),
                                ),
                              ),
                              Semantics(
                                container: true,
                                liveRegion: true,
                                label:
                                    controller.messages.isNotEmpty &&
                                        controller.messages.last.role ==
                                            ChatRole.assistant
                                    ? 'Jawaban baru tersedia dari Pendekar Gendut.'
                                    : null,
                                child: const SizedBox(width: 1, height: 1),
                              ),
                              ChatComposer(
                                controller: controller,
                                compact: compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _welcome(ChatController controller) => LayoutBuilder(
    key: ValueKey('welcome-${controller.conversation}'),
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: WelcomeSection(
          onSuggestion: (question) => controller.sendMessage(question),
        ),
      ),
    ),
  );

  Widget _conversation(ChatController controller) => LayoutBuilder(
    key: ValueKey('conversation-${controller.conversation}'),
    builder: (context, constraints) {
      final scroll = controller.scrollController;
      final messages = controller.messages;
      if (scroll.hasClients &&
          scroll.position.hasViewportDimension &&
          scroll.position.viewportDimension != constraints.maxHeight &&
          scroll.position.extentAfter <= 80) {
        controller.scrollToLatest();
      }
      return Scrollbar(
        controller: scroll,
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction != ScrollDirection.idle) {
              controller.cancelAutoScroll();
            }
            return false;
          },
          child: CustomScrollView(
            controller: scroll,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Center(
                      key: ValueKey(index),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: ChatBubble(message: messages[index]),
                      ),
                    ),
                    childCount: messages.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: controller.isLoading
                          ? const TypingIndicator()
                          : controller.errorMessage != null
                          ? ChatErrorMessage(
                              message: controller.errorMessage!,
                              onRetry: () => controller.retry(),
                              onEdit: controller.editFailedMessage,
                              onNewChat: controller.requiresNewConversation
                                  ? _newChat
                                  : null,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
