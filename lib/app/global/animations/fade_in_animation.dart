import 'package:flutter/material.dart';

class FadeInAnimation extends StatefulWidget {
  const FadeInAnimation({
    super.key,
    required this.child,
    required this.delay,
    required this.shouldAnimate,
  });

  final Widget child;
  final double delay;
  final bool shouldAnimate;

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with TickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;
  Animation<double>? animation2;

  @override
  void initState() {
    super.initState();
    // Initialize animations only if shouldAnimate is true
    if (widget.shouldAnimate) {
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    controller = AnimationController(
      duration: Duration(milliseconds: (500 * widget.delay).round()),
      vsync: this,
    );
    animation2 = Tween<double>(begin: -40, end: 0).animate(controller!)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    animation = Tween<double>(begin: 0, end: 1).animate(controller!)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldAnimate) {
      // Return the child widget directly if shouldAnimate is false
      return widget.child;
    }

    // Ensure animations are initialized
    if (controller == null || animation == null || animation2 == null) {
      _initializeAnimations();
    }

    // Animate if shouldAnimate is true
    return Transform.translate(
      offset: Offset(0, animation2!.value),
      child: Opacity(
        opacity: animation!.value,
        child: widget.child,
      ),
    );
  }

  @override
  void didUpdateWidget(FadeInAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate != oldWidget.shouldAnimate) {
      if (widget.shouldAnimate) {
        _initializeAnimations();
      } else {
        // Dispose of animations if shouldAnimate is set to false
        controller?.dispose();
        controller = null;
        animation = null;
        animation2 = null;
      }
    }
  }

  @override
  void dispose() {
    // Dispose of the controller if it was initialized
    controller?.dispose();
    super.dispose();
  }
}