import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/chat_controller.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    this.compact = false,
  });
  final ChatController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(context).width < 600 ? 12 : 28,
      compact ? 8 : 18,
      MediaQuery.sizeOf(context).width < 600 ? 12 : 28,
      compact ? 6 : 16,
    ),
    decoration: const BoxDecoration(
      color: Color(0xFF0B101D),
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C182B), Color(0xFF141D28)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.purple.withValues(alpha: .22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: .08),
                    blurRadius: 14,
                  ),
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: .05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (MediaQuery.sizeOf(context).width >= 600)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.bolt_outlined,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ),
                  Expanded(
                    child: Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      onKeyEvent: (node, event) {
                        final composing =
                            controller.inputController.value.composing;
                        if (composing.isValid && !composing.isCollapsed) {
                          return KeyEventResult.ignored;
                        }
                        final keyboard = HardwareKeyboard.instance;
                        final sends =
                            const SingleActivator(LogicalKeyboardKey.enter)
                                .accepts(event, keyboard) ||
                            const SingleActivator(
                              LogicalKeyboardKey.numpadEnter,
                            ).accepts(event, keyboard);
                        if (!sends) return KeyEventResult.ignored;
                        controller.sendMessage();
                        return KeyEventResult.handled;
                      },
                      child: TextField(
                        controller: controller.inputController,
                        focusNode: controller.inputFocus,
                        enabled: controller.canCompose,
                        minLines: 1,
                        maxLines: compact ? 2 : 4,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        decoration: InputDecoration(
                          hintText: controller.isLoading
                              ? 'Menunggu jawaban Pendekar Gendut…'
                              : controller.errorMessage != null
                              ? 'Coba lagi atau ubah pesan'
                              : 'Tulis pertanyaan tentang toko…',
                          hintStyle: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: compact ? 9 : 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.inputController,
                    builder: (context, value, _) => _SendButton(
                      enabled:
                          controller.canCompose && value.text.trim().isNotEmpty,
                      onSend: () => controller.sendMessage(),
                      compact: MediaQuery.sizeOf(context).width < 380,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Jawaban AI dari data simulasi Toko H Haris.',
                maxLines: compact ? 1 : null,
                overflow: compact ? TextOverflow.ellipsis : null,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SendButton extends StatefulWidget {
  const _SendButton({
    required this.enabled,
    required this.onSend,
    required this.compact,
  });
  final bool enabled;
  final VoidCallback onSend;
  final bool compact;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Kirim pesan',
    child: MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: !widget.enabled
            ? 1
            : _pressed
            ? .96
            : _hovered
            ? 1.03
            : 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 140),
        child: Semantics(
          button: true,
          enabled: widget.enabled,
          label: 'Kirim pesan',
          child: Opacity(
            opacity: widget.enabled ? 1 : .55,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.enabled ? widget.onSend : null,
                  onHighlightChanged: (value) =>
                      setState(() => _pressed = value),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.compact) ...[
                          const Text(
                            'Kirim',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 9),
                        ],
                        const Icon(
                          Icons.send_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
