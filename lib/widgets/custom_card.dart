import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool addBorder;
  final Color? borderColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.color,
    this.borderRadius,
    this.onTap,
    this.addBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultRadius = BorderRadius.circular(16);

    return Material(
      color: color ?? theme.cardColor,
      elevation: elevation,
      borderRadius: borderRadius ?? defaultRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? defaultRadius,
        child: Container(
          decoration: addBorder ? BoxDecoration(
            border: Border.all(
              color: borderColor ?? theme.primaryColor.withOpacity(0.5),
              width: 1.5,
            ),
            borderRadius: borderRadius ?? defaultRadius,
          ) : null,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

