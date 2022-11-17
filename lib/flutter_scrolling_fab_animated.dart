library flutter_scrolling_fab_animated;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Widget to animate the button when scroll down
class ScrollingFabAnimated extends StatefulWidget {
  /// Function to use when press the button
  final GestureTapCallback onPress;

  /// Double value to set the button elevation
  final double elevation;

  /// Value to set the duration for animation
  final Duration duration;

  /// Widget to use as button icon
  final Widget icon;

  final Size size;

  /// Widget to use as button text when button is expanded
  final Widget text;

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
  final bool animateIcon;

  /// Value to inverte the behavior of the animation
  final bool inverted;

  /// Double value to set the button radius
  final double? radius;

  final void Function(TabController tabController, void Function(bool inverted) size, void Function(bool active) visible)? customTabListener;

  final void Function(ScrollController scrollController, void Function(bool inverted) size, void Function(bool active) visible)? customScrollListener;

  final String? tooltipMessage;

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
    this.duration = const Duration(milliseconds: 500),
    this.curve,
    this.tooltipMessage,
    this.limitIndicator,
    this.size = const Size(120, 60),
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
  bool isVisible = true;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    if (widget.inverted) {
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
    if ((widget.limitIndicator != null ? scrollController.position.pixels > widget.limitIndicator! : true) &&
        scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() {
        _endTween = widget.inverted ? 100 : 0;
      });
    } else if ((widget.limitIndicator != null ? scrollController.position.pixels <= widget.limitIndicator! : true) &&
        scrollController.position.pixels > 30 &&
        scrollController.position.userScrollDirection == ScrollDirection.forward) {
      setState(() {
        _endTween = widget.inverted ? 0 : 100;
      });
    }
  }

  void _sizeTween(bool size) {
    setState(
      () {
        size ? _endTween = widget.inverted ? 0 : 100 : _endTween = widget.inverted ? 100 : 0;
      },
    );
  }

  void _visible(bool active) {
    setState(
      () {
        isVisible = active;
      },
    );
  }

  void _addListenerScroll() {
    if (widget.listScrollController == null) return;
    for (ScrollController scroll in widget.listScrollController!) {
      if (widget.customScrollListener != null) {
        scroll.addListener(() => widget.customScrollListener!(scroll, _sizeTween, _visible));
        continue;
      }
      scroll.addListener(() => _scrollListener(scroll));
    }
  }

  void _removeListenerScroll() {
    if (widget.listScrollController == null) return;
    for (ScrollController scroll in widget.listScrollController!) {
      if (widget.customScrollListener != null) {
        scroll.removeListener(() => widget.customScrollListener!(scroll, _sizeTween, _visible));
        continue;
      }
      scroll.removeListener(() => _scrollListener(scroll));
    }
  }

  void _addListenerTab() {
    if (widget.listTabController == null || widget.customTabListener == null) return;
    for (TabController tabController in widget.listTabController!) {
      tabController.addListener(() => widget.customTabListener!(tabController, _sizeTween, _visible));
    }
  }

  void _removeListenerTab() {
    if (widget.listTabController == null || widget.customTabListener == null) return;
    for (TabController tabController in widget.listTabController!) {
      tabController.removeListener(() => widget.customTabListener!(tabController, _sizeTween, _visible));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: FittedBox(
        clipBehavior: Clip.antiAlias,
        child: Card(
            elevation: widget.elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
            ),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: _endTween),
              duration: widget.duration,
              builder: (BuildContext _, double size, Widget? child) {
                final double widthPercent = (widget.size.width - widget.size.height).abs() / 100;
                final bool isFull = _endTween == 100;
                final double radius = widget.radius ?? (widget.size.height / 2);
                final widthFactor = ((math.pi / 250) * size).clamp(0.0, 1.0);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: widget.color ?? Theme.of(context).floatingActionButtonTheme.backgroundColor,
                  ),
                  clipBehavior: Clip.antiAlias,
                  constraints: BoxConstraints.tightFor(width: widget.size.height + (widthPercent * size), height: widget.size.height),
                  child: InkWell(
                    enableFeedback: true,
                    borderRadius: BorderRadius.circular(radius),
                    onTap: widget.onPress,
                    child: Tooltip(
                      message: widget.tooltipMessage ?? (widget.text as Text).data,
                      child: Row(
                        mainAxisAlignment: isFull ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            // child: Transform.rotate(
                            //   angle: widget.animateIcon ? (3.6 * math.pi / 180) * size : 0,
                            //   child: widget.icon,
                            // ),
                            child: Align(
                              widthFactor: widthFactor,
                              child: widget.icon,
                            ),
                          ),
                          if (isFull)
                            Expanded(
                              flex: widthFactor.toInt(),
                              child: Visibility(
                                visible: widthFactor >= 0.8,
                                child: Opacity(
                                  opacity: widthFactor,
                                  child: widget.text,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }
}
