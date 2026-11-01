import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/platform/external_links.dart';
import '../widgets/landing_components.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.onStartChat});
  final VoidCallback onStartChat;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _features = GlobalKey();
  final _technology = GlobalKey();

  void _show(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      alignment: .12,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 600;
          final inset = mobile ? 20.0 : 48.0;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1216),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: inset,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(child: LandingLogo()),
                                if (!mobile) ...[
                                  TextButton(
                                    onPressed: () => _show(_features),
                                    child: const Text('Fitur'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _show(_technology),
                                    child: const Text('Teknologi'),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: mobile
                                        ? constraints.maxWidth * .45
                                        : double.infinity,
                                  ),
                                  child: LandingButton(
                                    'Coba AI',
                                    onPressed: widget.onStartChat,
                                  ),
                                ),
                              ],
                            ),
                            if (mobile)
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () => _show(_features),
                                    child: const Text('Fitur'),
                                  ),
                                  TextButton(
                                    onPressed: () => _show(_technology),
                                    child: const Text('Teknologi'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.1,
                      colors: [AppColors.surface, AppColors.background],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      inset,
                      mobile ? 40 : 54,
                      inset,
                      0,
                    ),
                    child: Column(
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Asisten AI untuk UMKM.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: mobile ? 34 : 42,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 480),
                          child: Text(
                            'Bantu pelanggan menemukan produk, mengetahui harga, dan mengakses informasi toko melalui percakapan yang natural.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            LandingButton(
                              'Coba AI Sekarang',
                              onPressed: widget.onStartChat,
                            ),
                            LandingButton(
                              'Jelajahi Fitur',
                              onPressed: () => _show(_features),
                              secondary: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sidebar,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Demonstrasi · bukan percakapan langsung',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, letterSpacing: .3),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 626),
                          child: LandingChatPreview(
                            onStartChat: widget.onStartChat,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1216),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: inset),
                      child: Column(
                        children: [
                          SizedBox(height: mobile ? 64 : 104),
                          Semantics(
                            key: _features,
                            header: true,
                            child: const Text(
                              'Apa yang Bisa Dilakukan?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          LayoutBuilder(
                            builder: (context, box) {
                              const cards = [
                                LandingFeatureCard(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  title: 'Percakapan Natural',
                                  description: 'Ajukan pertanyaan tentang produk dan layanan toko dengan bahasa sehari-hari.',
                                ),
                                LandingFeatureCard(
                                  icon: Icons.search_rounded,
                                  title: 'Informasi Produk dan Harga',
                                  description: 'Membantu menemukan informasi produk dan harga berdasarkan katalog simulasi toko.',
                                ),
                                LandingFeatureCard(
                                  icon: Icons.recommend_outlined,
                                  title: 'Rekomendasi Produk',
                                  description: 'Temukan pilihan produk dan alternatif yang sesuai dengan kebutuhan Anda berdasarkan katalog toko.',
                                ),
                              ];
                              if (box.maxWidth < 700) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0; i < cards.length; i++) ...[
                                      if (i > 0) const SizedBox(height: 16),
                                      cards[i],
                                    ],
                                  ],
                                );
                              }
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0; i < cards.length; i++) ...[
                                      if (i > 0) const SizedBox(width: 24),
                                      Expanded(child: cards[i]),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: mobile ? 56 : 88),
                          Semantics(
                            key: _technology,
                            header: true,
                            child: const Text(
                              'Teknologi yang Digunakan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              for (final tech in [
                                ('Flutter Web', AppColors.cyan),
                                ('FastAPI', AppColors.green),
                                ('Google Gemini', AppColors.purple),
                                ('Firebase Hosting', AppColors.purple),
                                ('Vercel', AppColors.text),
                              ])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.panel,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 7,
                                        color: tech.$2,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          tech.$1,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 52),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: mobile ? 24 : 48,
                              vertical: 36,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.panel,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .1),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    'Coba Pendekar Gendut AI.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: mobile ? 28 : 36,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 430),
                                  child: Text(
                                    'Jelajahi pengalaman berinteraksi dengan asisten AI untuk simulasi layanan pelanggan UMKM.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, height: 1.6),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                LandingButton(
                                  'Mulai Percakapan',
                                  onPressed: widget.onStartChat,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: AppColors.background,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1216),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(inset, 24, inset, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LandingLogo(small: true),
                            TextButton.icon(
                              onPressed: supportsExternalLinks
                                  ? () => openExternalLink(
                                      'https://github.com/Akhdan1998/pendekar-gendut-chatbot',
                                    )
                                  : null,
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('GitHub'),
                            ),
                            const SizedBox(height: 18),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 18),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 32,
                              runSpacing: 12,
                              children: [
                                Text(
                                  '© ${DateTime.now().year} Pendekar Gendut AI. Seluruh hak cipta dilindungi.',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Text(
                                  'Proyek demonstrasi dengan data produk simulasi.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
