import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/chat_controller.dart';
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
  final _statusKey = GlobalKey();

  @override
  void dispose() {
    _controller.onClose();
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
        final compact = availableHeight < 360;
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

  Widget _conversation(ChatController controller) {
    final messages = controller.messages;
    final scroll = controller.scrollController;
    final statusBox =
        _statusKey.currentContext?.findRenderObject() as RenderBox?;
    final statusHeight = statusBox?.hasSize == true
        ? statusBox!.size.height
        : null;
    if (statusHeight != null && scroll.hasClients && scroll.offset > 80) {
      final position = scroll.position;
      final conversation = controller.conversation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            conversation != controller.conversation ||
            !scroll.hasClients ||
            scroll.position != position ||
            position.isScrollingNotifier.value) {
          return;
        }
        final newHeight = _statusKey.currentContext?.size?.height;
        if (newHeight == null || newHeight == statusHeight) return;
        // Keyed messages retain their anchor; the changing status row does not.
        position.jumpTo(
          (position.pixels + statusHeight - newHeight).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          ),
        );
      });
    }
    return Scrollbar(
      key: ValueKey('conversation-${controller.conversation}'),
      controller: controller.scrollController,
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction != ScrollDirection.idle) {
            controller.cancelAutoScroll();
          }
          return false;
        },
        child: CustomScrollView(
          controller: controller.scrollController,
          // The newest message stays anchored when the keyboard resizes the view.
          reverse: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: SizedBox(
                      key: _statusKey,
                      child: controller.isLoading
                          ? const TypingIndicator()
                          : controller.errorMessage != null
                          ? ChatErrorMessage(
                              message: controller.errorMessage ?? '',
                              onRetry: () => controller.retry(),
                              onEdit: controller.editFailedMessage,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final messageIndex = messages.length - index - 1;
                    return Center(
                      key: ValueKey(messageIndex),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: ChatBubble(message: messages[messageIndex]),
                      ),
                    );
                  },
                  childCount: messages.length,
                  findChildIndexCallback: (key) {
                    if (key is ValueKey<int> &&
                        key.value >= 0 &&
                        key.value < messages.length) {
                      return messages.length - key.value - 1;
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
