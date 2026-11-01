import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/l10n/app_strings.dart';
import '../../chat/widgets/assistant_avatar.dart';
import '../../chat/widgets/chat_bubble.dart';
import '../../chat/models/chat_message.dart';

class LandingButton extends StatelessWidget {
  const LandingButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.secondary = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) =>
      AppButton(onPressed: onPressed, secondary: secondary, child: Text(label));
}

class LandingLogo extends StatelessWidget {
  const LandingLogo({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AssistantAvatar(size: small ? 28 : 36),
      SizedBox(width: small ? 8 : 10),
      Flexible(
        child: Text(
          AppStrings.brand,
          style: TextStyle(
            fontSize: small ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class LandingFeatureCard extends StatelessWidget {
  const LandingFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.sidebar,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 19, color: AppColors.purple),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: AppColors.muted,
          ),
        ),
      ],
    ),
  );
}

class LandingChatPreview extends StatelessWidget {
  const LandingChatPreview({super.key, required this.onStartChat});
  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.sidebar,
          padding: const EdgeInsets.all(16),
          child: const Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              LandingLogo(small: true),
              Text(
                'Pratinjau Chatbot',
                style: TextStyle(color: AppColors.cyan, fontSize: 13),
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Contoh percakapan statis. Anda: Apakah bisa membayar dengan QRIS? Pendekar Gendut: Bisa. Dalam simulasi Toko H Haris, pembayaran tersedia melalui tunai, transfer bank, dan QRIS.',
          excludeSemantics: true,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              children: [
                ChatBubble(
                  message: ChatMessage(
                    role: ChatRole.user,
                    content: 'Apakah bisa membayar dengan QRIS?',
                  ),
                ),
                ChatBubble(
                  message: ChatMessage(
                    role: ChatRole.assistant,
                    content: 'Bisa. Dalam simulasi Toko H Haris, pembayaran tersedia melalui tunai, transfer bank, dan QRIS.',
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: AppColors.sidebar,
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text(
                'Contoh percakapan statis, bukan jawaban AI langsung.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              LandingButton('Coba AI', onPressed: onStartChat),
            ],
          ),
        ),
      ],
    ),
  );
}
