import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SuggestionCard extends StatefulWidget {
  const SuggestionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.compact = false,
  });
  final bool compact;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: widget.compact ? 60 : 120),
    child: MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withValues(alpha: .09)
              : AppColors.panel.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: _hovered
                ? widget.color.withValues(alpha: .6)
                : AppColors.border,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: widget.compact ? 12 : 16,
              ),
              child: Row(
                crossAxisAlignment: widget.compact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: widget.color.withValues(alpha: .25),
                      ),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 18),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!widget.compact) ...[
                          const SizedBox(height: 5),
                          Text(
                            widget.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
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
