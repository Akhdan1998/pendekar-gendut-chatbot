import 'package:flutter/material.dart';

class LandingColors {
  LandingColors._();
  static const background = Color(0xFF0D1320);
  static const card = Color(0xFF151B29);
  static const panel = Color(0xFF202635);
  static const border = Color(0xFF272E3D);
  static const blue = Color(0xFF4C8DFF);
  static const text = Color(0xFFDFE4F6);
}

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
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24),
      ),
      backgroundColor: WidgetStatePropertyAll(
        secondary ? LandingColors.panel : LandingColors.blue,
      ),
      foregroundColor: WidgetStatePropertyAll(
        secondary ? LandingColors.text : const Color(0xFF061329),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? Colors.white
              : LandingColors.border,
          width: states.contains(WidgetState.focused) ? 2 : 1,
        ),
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)
            ? Colors.white.withValues(alpha: .16)
            : null,
      ),
    ),
    child: Text(label),
  );
}

class LandingLogo extends StatelessWidget {
  const LandingLogo({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: small ? 22 : 28,
        height: small ? 22 : 28,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2D4D),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF506A99)),
        ),
        child: Icon(
          Icons.smart_toy_outlined,
          size: small ? 13 : 16,
          color: const Color(0xFFB9CEFF),
        ),
      ),
      SizedBox(width: small ? 8 : 10),
      Flexible(
        child: Text(
          'Pendekar Gendut AI',
          style: TextStyle(
            fontSize: small ? 11 : 14,
            fontWeight: FontWeight.w500,
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
      color: LandingColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: LandingColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF222C40),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFF3B4965)),
          ),
          child: Icon(icon, size: 19, color: const Color(0xFFB9CEFF)),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 12, height: 1.55)),
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
      color: LandingColors.background,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: LandingColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .16),
          blurRadius: 32,
          offset: const Offset(0, 20),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          color: LandingColors.panel,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: const Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              LandingLogo(small: true),
              Text(
                'Contoh chat',
                style: TextStyle(fontSize: 10, color: Color(0xFF81E5B0)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2C4C),
                  border: Border.all(color: const Color(0xFF506A99)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: const Text(
                  'Apa yang bisa saya tanyakan di sini?',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: LandingColors.panel,
                    child: Icon(
                      Icons.smart_toy_outlined,
                      size: 14,
                      color: Color(0xFFB9CEFF),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF232B3A),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Halo! Saya Pendekar Gendut. Saya bisa membantu mencari informasi produk, harga, dan layanan Toko H Haris.',
                          style: TextStyle(fontSize: 11, height: 1.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: LandingColors.panel,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF070F1B),
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Contoh tampilan chat · coba AI untuk bertanya',
                      style: TextStyle(fontSize: 11, color: Color(0xFFABB4C8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onStartChat,
                tooltip: 'Buka chatbot untuk mengirim pertanyaan',
                style: IconButton.styleFrom(
                  backgroundColor: LandingColors.blue,
                  foregroundColor: const Color(0xFF061329),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                icon: const Icon(Icons.send_outlined, size: 18),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
