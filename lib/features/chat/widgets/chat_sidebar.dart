import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'active_conversation_card.dart';
import 'store_information_card.dart';

class ChatSidebar extends StatelessWidget {
  const ChatSidebar({
    super.key,
    required this.title,
    required this.hasMessages,
    required this.onNewChat,
    required this.onConversation,
  });
  final String title;
  final bool hasMessages;
  final VoidCallback onNewChat;
  final VoidCallback onConversation;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.sidebar,
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 40).clamp(0, double.infinity),
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.sidebar,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.brightness_1_rounded,
                            color: AppColors.cyan,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UMKM AI Chatbot',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '• Toko H Haris',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sidebar,
                        foregroundColor: AppColors.text,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onNewChat,
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 19,
                        color: AppColors.purple,
                      ),
                      label: const Text('Chat Baru'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'PERCAKAPAN SAAT INI',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ActiveConversationCard(
                    title: title,
                    hasMessages: hasMessages,
                    onConversation: onConversation,
                  ),
                  const SizedBox(height: 10),
                  const StoreInformationCard(),
                  const Spacer(),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toko H Haris',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Informasi toko simulasi',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
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
}
