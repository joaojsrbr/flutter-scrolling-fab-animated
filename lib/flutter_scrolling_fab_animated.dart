library flutter_scrolling_fab_animated;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Widget to animate the button when scroll down
class ScrollingFabAnimated extends StatefulWidget {
  /// Function to use when press the button
  final GestureTapCallback? onPress;

  /// Double value to set the button elevation
  final double? elevation;

  /// Double value to set the button width
  final double? width;

  /// Double value to set the button height
  final double? height;

  /// Value to set the duration for animation
  final Duration? duration;

  /// Widget to use as button icon
  final Widget? icon;

  /// Widget to use as button text when button is expanded
  final Widget? text;

  /// Value to set the curve for animation
  final Curve? curve;

  /// ScrollController to use to determine when user is on top or not
  final List<ScrollController>? listScrollController;

  final List<TabController>? listTabController;

  /// Double value to set the boundary value when scroll animation is triggered
  final double? limitIndicator;

  /// Color to set the button background color
  final Color? color;

  /// Value to indicate if animate or not the icon
  final bool? animateIcon;

  /// Value to inverte the behavior of the animation
  final bool? inverted;

  /// Double value to set the button radius
  final double? radius;

  final void Function(TabController tabController, void Function(bool inverted) size)? customTabListener;

  final void Function(ScrollController scrollController, void Function(bool inverted) size)? customScrollListener;

  const ScrollingFabAnimated({
    super.key,
    required this.icon,
    required this.text,
    required this.onPress,
    this.listTabController,
    this.customTabListener,
    this.customScrollListener,
    this.listScrollController,
    this.elevation = 5.0,
    this.width = 120.0,
    this.height = 60.0,
    this.duration = const Duration(milliseconds: 250),
    this.curve,
    this.limitIndicator = 10.0,
    this.color,
    this.animateIcon = true,
    this.inverted = false,
    this.radius,
  });

  @override
  _ScrollingFabAnimatedState createState() => _ScrollingFabAnimatedState();
}

class _ScrollingFabAnimatedState extends State<ScrollingFabAnimated> {
  /// Double value for tween ending
  double _endTween = 100;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    if (widget.inverted!) {
      setState(() {
        _endTween = 0;
      });
    }
    _addListenerScroll();
    _addListenerTab();
  }

  @override
  void dispose() {
    _removeListenerScroll();
    _removeListenerTab();
    super.dispose();
  }

  void _scrollListener(ScrollController scrollController) {
    if (scrollController.position.pixels > widget.limitIndicator! && scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() {
        _endTween = widget.inverted! ? 100 : 0;
      });
    } else if (scrollController.position.pixels <= widget.limitIndicator! &&
        scrollController.position.userScrollDirection == ScrollDirection.forward) {
      setState(() {
        _endTween = widget.inverted! ? 0 : 100;
      });
    }
  }

  void sizeTween(bool size) {
    setState(
      () {
        size ? _endTween = widget.inverted! ? 0 : 100 : _endTween = widget.inverted! ? 100 : 0;
      },
    );
  }

  void _addListenerScroll() {
    if (widget.listScrollController == null) return;
    for (ScrollController scroll in widget.listScrollController!) {
      if (widget.customScrollListener != null) {
        scroll.addListener(() => widget.customScrollListener!(scroll, sizeTween));
        continue;
      }
      scroll.addListener(() => _scrollListener(scroll));
    }
  }

  void _removeListenerScroll() {
    if (widget.listScrollController == null) return;
    for (ScrollController scroll in widget.listScrollController!) {
      if (widget.customScrollListener != null) {
        scroll.removeListener(() => widget.customScrollListener!(scroll, sizeTween));
        continue;
      }
      scroll.removeListener(() => _scrollListener(scroll));
    }
  }

  void _addListenerTab() {
    if (widget.listTabController == null || widget.customTabListener == null) return;
    for (TabController tabController in widget.listTabController!) {
      tabController.addListener(() => widget.customTabListener!(tabController, sizeTween));
    }
  }

  void _removeListenerTab() {
    if (widget.listTabController == null || widget.customTabListener == null) return;
    for (TabController tabController in widget.listTabController!) {
      tabController.removeListener(() => widget.customTabListener!(tabController, sizeTween));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(widget.height! / 2))),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: _endTween),
          duration: widget.duration!,
          builder: (BuildContext _, double size, Widget? child) {
            double _widthPercent = (widget.width! - widget.height!).abs() / 100;
            bool _isFull = _endTween == 100;
            double _radius = widget.radius ?? (widget.height! / 2);
            return Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(_radius)), color: widget.color ?? Theme.of(context).primaryColor),
              height: widget.height,
              width: widget.height! + _widthPercent * size,
              child: InkWell(
                onTap: widget.onPress,
                child: Ink(
                  child: Row(
                    mainAxisAlignment: _isFull ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Transform.rotate(
                            angle: widget.animateIcon! ? (3.6 * math.pi / 180) * size : 0,
                            child: widget.icon,
                          )),
                      ...(_isFull
                          ? [
                              Expanded(
                                child: AnimatedOpacity(
                                  opacity: size > 90 ? 1 : 0,
                                  duration: const Duration(milliseconds: 100),
                                  child: widget.text!,
                                ),
                              )
                            ]
                          : []),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
