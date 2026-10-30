import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StoreInformationCard extends StatelessWidget {
  const StoreInformationCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.panel.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: AppColors.cyan),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Informasi Toko',
                style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Senin–Sabtu, 08:00–20:00 WIB\nMinggu tutup.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.7),
        ),
        SizedBox(height: 9),
        Text(
          'Tunai, transfer bank, dan QRIS.\nPengantaran tidak tersedia.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.7),
        ),
        SizedBox(height: 10),
        Text(
          '✓ QRIS tersedia  •  Data simulasi',
          style: TextStyle(color: AppColors.green, fontSize: 12),
        ),
      ],
    ),
  );
}
