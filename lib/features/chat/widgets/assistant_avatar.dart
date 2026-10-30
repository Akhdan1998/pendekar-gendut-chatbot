import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AssistantAvatar extends StatefulWidget {
  const AssistantAvatar({super.key, this.size = 42, this.animate = false});
  final double size;
  final bool animate;

  @override
  State<AssistantAvatar> createState() => _AssistantAvatarState();
}

class _AssistantAvatarState extends State<AssistantAvatar>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      _animation.repeat(reverse: true);
    } else {
      _animation.stop();
      _animation.value = 0;
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, _) => Container(
      width: widget.size,
      height: widget.size,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(widget.size * .25),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(
              alpha: .15 + _animation.value * .12,
            ),
            blurRadius: widget.animate ? 32 + _animation.value * 12 : 10,
            spreadRadius: widget.animate ? 3 : 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(widget.size * .25 - 1),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => AppColors.gradient.createShader(bounds),
          child: Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: widget.size * .56,
          ),
        ),
      ),
    ),
  );
}
