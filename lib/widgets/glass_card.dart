import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  
  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radius),
      child: BackdropFilter(
        // backdrop-filter: blur(14px) saturate(170%)
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // background: hsla(var(--glass))
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(AppColors.radius),
            // border: 1px solid hsla(var(--glass-border))
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
            // box-shadow: var(--shadow-glass)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
