import 'package:flutter/material.dart';

class FadeInAnimation extends StatefulWidget {
  const FadeInAnimation({
    super.key,
    required this.child,
    required this.delay,
    required this.shouldAnimate,
    this.fromLeft = false,
    this.fromRight = false,
    this.fromBottom = false,
  });

  final Widget child;
  final double delay;
  final bool shouldAnimate;
  final bool fromLeft;
  final bool fromRight;
  final bool fromBottom;

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with TickerProviderStateMixin {
  static const double _slideDistance = 40;

  AnimationController? controller;
  Animation<double>? animation;
  Animation<double>? animation2;

  /// Only one direction is active. Right, then left, then bottom, else top.
  Offset get _beginOffset {
    if (widget.fromRight) return const Offset(_slideDistance, 0);
    if (widget.fromLeft) return const Offset(-_slideDistance, 0);
    if (widget.fromBottom) return const Offset(0, _slideDistance);
    return const Offset(0, -_slideDistance);
  }

  @override
  void initState() {
    super.initState();
    if (widget.shouldAnimate) {
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    controller?.dispose();
    controller = AnimationController(
      duration: Duration(milliseconds: (500 * widget.delay).round()),
      vsync: this,
    );
    animation2 = Tween<double>(begin: 1, end: 0).animate(controller!)
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
      return widget.child;
    }

    if (controller == null || animation == null || animation2 == null) {
      _initializeAnimations();
    }

    return Transform.translate(
      offset: _beginOffset * animation2!.value,
      child: Opacity(
        opacity: animation!.value,
        child: widget.child,
      ),
    );
  }

  @override
  void didUpdateWidget(FadeInAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    final directionChanged = widget.fromLeft != oldWidget.fromLeft ||
        widget.fromRight != oldWidget.fromRight ||
        widget.fromBottom != oldWidget.fromBottom;

    if (widget.shouldAnimate != oldWidget.shouldAnimate ||
        (widget.shouldAnimate && directionChanged)) {
      if (widget.shouldAnimate) {
        _initializeAnimations();
      } else {
        controller?.dispose();
        controller = null;
        animation = null;
        animation2 = null;
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
