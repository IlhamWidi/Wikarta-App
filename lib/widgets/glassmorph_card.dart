import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassmorphCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final GestureTapCallback? onTap;
  final bool animated;

  const GlassmorphCard({
    Key? key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final core = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: AppColors.skyBlue.withOpacity(0.13), width: 1.2),
      ),
      child: child,
    );
    return onTap != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onTap,
              child: core,
            ),
          )
        : core;
  }
}