import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ActiveConversationCard extends StatelessWidget {
  const ActiveConversationCard({
    super.key,
    required this.title,
    required this.hasMessages,
    required this.onConversation,
  });
  final String title;
  final bool hasMessages;
  final VoidCallback onConversation;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: hasMessages ? onConversation : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.purple.withValues(alpha: .08),
              AppColors.sidebar,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.purple.withValues(alpha: .25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.purple,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasMessages ? title : 'Belum ada pesan',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasMessages
                            ? 'Kembali ke percakapan'
                            : 'Mulai bertanya tentang toko',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasMessages)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.purple,
                    size: 18,
                  ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Riwayat tidak disimpan permanen.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
