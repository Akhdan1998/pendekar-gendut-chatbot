import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import 'assistant_avatar.dart';
import 'entrance.dart';
import 'suggestion_card.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key, required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  static const _suggestions = [
    (
      title: 'Produk apa saja yang tersedia?',
      subtitle: 'Lihat informasi produk pada data toko',
      icon: Icons.shopping_bag_outlined,
      color: AppColors.purple,
    ),
    (
      title: 'Berapa harga beras Ramos?',
      subtitle: 'Tanyakan harga dan ketersediaan stok',
      icon: Icons.paid_outlined,
      color: AppColors.cyan,
    ),
    (
      title: 'Toko buka jam berapa?',
      subtitle: 'Lihat jadwal operasional toko',
      icon: Icons.schedule_rounded,
      color: AppColors.pink,
    ),
    (
      title: 'Apakah bisa bayar dengan QRIS?',
      subtitle: 'Tunai, transfer bank, dan QRIS',
      icon: Icons.credit_card_rounded,
      color: AppColors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final tablet = MediaQuery.sizeOf(context).width < 1100;
    return Entrance(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: mobile
                  ? 16
                  : tablet
                  ? 24
                  : 32,
              horizontal: 22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssistantAvatar(
                  size: mobile
                      ? 56
                      : tablet
                      ? 72
                      : 88,
                  animate: true,
                ),
                SizedBox(
                  height: mobile
                      ? 12
                      : tablet
                      ? 20
                      : 26,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: mobile ? 3 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: .25),
                    ),
                  ),
                  child: const Text(
                    '•  ${AppStrings.assistant} Toko H Haris',
                    style: TextStyle(color: AppColors.purple, fontSize: 12),
                  ),
                ),
                SizedBox(height: mobile ? 10 : 16),
                Text(
                  'Halo! Saya Pendekar Gendut, asisten virtual Toko H Haris. Ada yang bisa saya bantu?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: mobile
                        ? 24
                        : tablet
                        ? 28
                        : 30,
                    height: 1.2,
                    letterSpacing: -.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: mobile ? 10 : 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: const Text(
                    'Tanyakan produk, harga, stok, atau jam operasional toko.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(
                  height: mobile
                      ? 18
                      : tablet
                      ? 24
                      : 28,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      return Column(
                        children: [
                          for (
                            var index = 0;
                            index < _suggestions.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(height: 8),
                            _suggestion(index, compact: true),
                          ],
                        ],
                      );
                    }
                    return Column(
                      children: [
                        for (
                          var index = 0;
                          index < _suggestions.length;
                          index += 2
                        ) ...[
                          if (index > 0) const SizedBox(height: 14),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _suggestion(index)),
                                const SizedBox(width: 14),
                                Expanded(child: _suggestion(index + 1)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                SizedBox(height: mobile ? 12 : 20),
                const Text(
                  'Pilih pertanyaan atau tulis pesan Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestion(int index, {bool compact = false}) {
    final item = _suggestions[index];
    return SuggestionCard(
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      color: item.color,
      compact: compact,
      onTap: () => onSuggestion(item.title),
    );
  }
}
