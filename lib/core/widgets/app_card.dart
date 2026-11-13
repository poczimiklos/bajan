import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final shape = BeveledRectangleBorder(
      side: BorderSide(color: AppColors.gold.withValues(alpha: 0.32)),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.985, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, content) => Opacity(
        opacity: value,
        child: Transform.scale(scale: value, child: content),
      ),
      child: Material(
        color: color ?? context.cardBg,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: context.accent.withValues(alpha: 0.12),
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
