import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'assistant_avatar.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    this.onMenu,
    this.onNewChat,
    this.compact = false,
  });
  final bool compact;
  final VoidCallback? onMenu;
  final VoidCallback? onNewChat;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: onMenu == null ? 22 : 8,
      vertical: compact ? 6 : 14,
    ),
    decoration: const BoxDecoration(
      color: Color(0xFF0C1120),
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        if (onMenu != null)
          IconButton(
            tooltip: 'Buka menu',
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded, size: 22),
          ),
        const AssistantAvatar(size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Pendekar Gendut',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onMenu == null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: .2),
                        ),
                      ),
                      child: const Text(
                        'Pelayan AI',
                        style: TextStyle(color: AppColors.cyan, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Pelayan Toko H Haris',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        if (onNewChat != null)
          IconButton(
            tooltip: 'Chat Baru',
            onPressed: onNewChat,
            icon: const Icon(Icons.add_comment_outlined, size: 21),
          ),
      ],
    ),
  );
}
