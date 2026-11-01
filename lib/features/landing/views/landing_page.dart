import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LandingColors.text,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: LandingColors.text,
        displayColor: LandingColors.text,
      ),
    ),
    child: Scaffold(
      backgroundColor: LandingColors.background,
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
                      border: Border(
                        bottom: BorderSide(color: LandingColors.border),
                      ),
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
                                  LandingButton(
                                    'Coba AI',
                                    onPressed: widget.onStartChat,
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
                        colors: [Color(0xFF111D35), LandingColors.background],
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
                              'Bantu pelanggan menemukan produk, mengecek harga, dan mendapatkan informasi toko melalui percakapan yang natural.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.6),
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
                                'Lihat Fitur',
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
                              color: LandingColors.panel,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: LandingColors.border),
                            ),
                            child: const Text(
                              'Demonstrasi · bukan percakapan langsung',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, letterSpacing: .3),
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
                                    description: 'Memahami bahasa percakapan sehari-hari, singkatan belanja, dan ragam pertanyaan pembeli tanpa kaku.',
                                  ),
                                  LandingFeatureCard(
                                    icon: Icons.search_rounded,
                                    title: 'Pencarian Produk & Harga',
                                    description: 'Memberikan informasi ketersediaan sembako dan harga terkini secara instan dan akurat.',
                                  ),
                                  LandingFeatureCard(
                                    icon: Icons.recommend_outlined,
                                    title: 'Rekomendasi Produk',
                                    description: 'Membantu merekomendasikan alternatif komoditas atau produk pelengkap dengan ramah dan santun.',
                                  ),
                                ];
                                if (box.maxWidth < 700) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      for (
                                        var i = 0;
                                        i < cards.length;
                                        i++
                                      ) ...[
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
                                      for (
                                        var i = 0;
                                        i < cards.length;
                                        i++
                                      ) ...[
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
                                'BUILT WITH MODERN TECHNOLOGY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
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
                                  ('Flutter Web', const Color(0xFFB9CEFF)),
                                  ('FastAPI', const Color(0xFF61D99F)),
                                  ('Google Gemini', LandingColors.blue),
                                  ('Firebase', const Color(0xFFD9C2FF)),
                                  ('Vercel', LandingColors.text),
                                ])
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: LandingColors.card,
                                      border: Border.all(
                                        color: LandingColors.border,
                                      ),
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
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                            ),
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
                                color: LandingColors.card,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: LandingColors.border),
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
                                      'Jelajahi pengalaman berinteraksi dengan asisten AI untuk simulasi toko UMKM.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  LandingButton(
                                    'Mulai Chat',
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
                    color: const Color(0xFF070F1B),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1216),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(inset, 24, inset, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const LandingLogo(small: true),
                              const SizedBox(height: 18),
                              const Divider(
                                color: LandingColors.border,
                                height: 1,
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 32,
                                runSpacing: 12,
                                children: [
                                  Text(
                                    '© ${DateTime.now().year} Pendekar Gendut AI. All rights reserved.',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const Text(
                                    'Proyek demonstrasi dengan data produk simulasi.',
                                    style: TextStyle(fontSize: 10),
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
    ),
  );
}
