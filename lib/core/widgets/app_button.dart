import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.secondary = false,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final bool secondary;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: secondary ? null : AppColors.gradient,
      borderRadius: BorderRadius.circular(16),
    ),
    child: FilledButton(
      onPressed: onPressed,
      style: Theme.of(context).filledButtonTheme.style?.copyWith(
        // Darken the gradient so white labels retain contrast at its cyan end.
        backgroundColor: WidgetStatePropertyAll(
          secondary
              ? AppColors.panel
              : Colors.black.withValues(alpha: onPressed == null ? .65 : .4),
        ),
      ),
      child: child,
    ),
  );
}
