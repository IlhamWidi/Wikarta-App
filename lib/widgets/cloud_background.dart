import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CloudBackground extends StatelessWidget {
  final Widget child;
  const CloudBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cloud shapes
        Positioned(
          top: -80,
          left: -40,
          child: _cloud(180, AppColors.card2.withOpacity(0.7)),
        ),
        Positioned(
          top: 70,
          right: -60,
          child: _cloud(140, AppColors.card.withOpacity(0.5)),
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: _cloud(110, AppColors.skyBlue.withOpacity(0.32)),
        ),
        child,
      ],
    );
  }

  Widget _cloud(double size, Color color) => Container(
        width: size,
        height: size * 0.60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
        ),
      );
}