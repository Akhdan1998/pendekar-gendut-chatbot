import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';

class ChatErrorMessage extends StatelessWidget {
  const ChatErrorMessage({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onEdit,
    this.onNewChat,
  });
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onEdit;
  final VoidCallback? onNewChat;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.replyError,
                  style: const TextStyle(fontSize: 13, color: AppColors.danger),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          Wrap(
            spacing: 8,
            children: [
              if (onNewChat != null)
                TextButton.icon(
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  label: const Text(AppStrings.newConversation),
                )
              else ...[
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(AppStrings.retry),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Ubah pesan'),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
