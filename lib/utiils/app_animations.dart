// import 'package:flutter/material.dart';
// import 'package:simple_animations/simple_animations.dart';
// import 'package:supercharged/supercharged.dart';
//
// enum AnimationProps { opacity, translateY }
//
// class FadeAnimation extends StatelessWidget {
//   final double delay;
//   final Widget child;
//
//   const FadeAnimation(this.delay, this.child);
//
//   @override
//   Widget build(BuildContext context) {
//     final tween = MultiTween<AnimationProps>()
//       ..add(AnimationProps.opacity, 0.0.tweenTo(1.0), 500.milliseconds)
//       ..add(AnimationProps.translateY, 30.0.tweenTo(0.0), 500.milliseconds, Curves.easeOut);
//
//     return PlayAnimation<MultiTweenValues<AnimationProps>>(
//       delay: Duration(milliseconds: (500 * delay).round()),
//       duration: tween.duration,
//       tween: tween,
//       child: child,
//       builder: (context, child, value) => Opacity(
//         opacity: value.get(AnimationProps.opacity),
//         child: Transform.translate(
//           offset: Offset(0, value.get(AnimationProps.translateY)),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// class SlideAnimation extends StatelessWidget {
//   final double delay;
//   final Widget child;
//   final bool fromLeft;
//
//   SlideAnimation(this.delay, this.child, {this.fromLeft = true});
//
//   @override
//   Widget build(BuildContext context) {
//     final tween = MultiTween<AnimationProps>()
//       ..add(AnimationProps.opacity, 0.0.tweenTo(1.0), 400.milliseconds)
//       ..add(
//           AnimationProps.translateY,
//           (fromLeft ? -30.0 : 30.0).tweenTo(0.0),
//           400.milliseconds,
//           Curves.easeOut
//       );
//
//     return PlayAnimation<MultiTweenValues<AnimationProps>>(
//       delay: Duration(milliseconds: (300 * delay).round()),
//       duration: tween.duration,
//       tween: tween,
//       child: child,
//       builder: (context, child, value) => Opacity(
//         opacity: value.get(AnimationProps.opacity),
//         child: Transform.translate(
//           offset: Offset(value.get(AnimationProps.translateY), 0),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// class PulseAnimation extends StatelessWidget {
//   final Widget child;
//   final bool infinite;
//
//   PulseAnimation({required this.child, this.infinite = false});
//
//   @override
//   Widget build(BuildContext context) {
//     final tween = MultiTween<AnimationProps>()
//       ..add(AnimationProps.opacity, 0.5.tweenTo(1.0), 700.milliseconds)
//       ..add(AnimationProps.translateY, 1.05.tweenTo(1.0), 700.milliseconds, Curves.easeInOut);
//
//     return PlayAnimation<MultiTweenValues<AnimationProps>>(
//       tween: tween,
//       duration: tween.duration,
//       child: child,
//       builder: (context, child, value) => Opacity(
//         opacity: value.get(AnimationProps.opacity),
//         child: Transform.scale(
//           scale: value.get(AnimationProps.translateY),
//           child: child,
//         ),
//       ),
//       playback: infinite ? Playback.loop : Playback.normal,
//     );
//   }
// }
//
