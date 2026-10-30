import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';
import 'assistant_avatar.dart';
import 'entrance.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Entrance(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const AssistantAvatar(size: 32),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 650),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF28203F) : AppColors.panel,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(17),
                    topRight: const Radius.circular(17),
                    bottomLeft: Radius.circular(isUser ? 17 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 17),
                  ),
                  border: Border.all(
                    color: message.status == MessageStatus.failed
                        ? AppColors.danger.withValues(alpha: .5)
                        : isUser
                        ? AppColors.purple.withValues(alpha: .25)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isUser ? 'Anda' : 'Pendekar Gendut',
                      style: TextStyle(
                        fontSize: 12,
                        color: isUser ? AppColors.purple : AppColors.cyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (isUser)
                      SelectableText(
                        message.content,
                        style: const TextStyle(fontSize: 14, height: 1.65),
                      )
                    else
                      MarkdownBody(
                        data: message.content,
                        selectable: true,
                        softLineBreak: true,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(
                                  p: const TextStyle(
                                    fontSize: 14,
                                    height: 1.65,
                                    color: AppColors.text,
                                  ),
                                  listBullet: const TextStyle(
                                    fontSize: 14,
                                    height: 1.65,
                                    color: AppColors.text,
                                  ),
                                  blockSpacing: 10,
                                  a: const TextStyle(color: AppColors.cyan),
                                ),
                        imageBuilder: (uri, title, alt) => Text(alt ?? ''),
                      ),
                    if (message.status == MessageStatus.failed) ...[
                      const SizedBox(height: 7),
                      const Text(
                        'Belum terkirim',
                        style: TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ],
                    if (message.responseTimeMs case final duration?) ...[
                      const SizedBox(height: 7),
                      Text(
                        'Waktu respons: ${(duration / 1000).toStringAsFixed(1)} detik',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isUser) const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}
