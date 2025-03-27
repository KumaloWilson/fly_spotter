import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFlyIcon extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;

  const AnimatedFlyIcon({
    Key? key,
    this.size = 100,
    this.color = Colors.white,
    this.animate = true,
  }) : super(key: key);

  @override
  _AnimatedFlyIconState createState() => _AnimatedFlyIconState();
}

class _AnimatedFlyIconState extends State<AnimatedFlyIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: math.sin(_controller.value * math.pi * 2) * _rotationAnimation.value,
            child: Icon(
              Icons.bug_report,
              size: widget.size,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

