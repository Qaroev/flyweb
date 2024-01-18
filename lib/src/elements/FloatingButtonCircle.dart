import 'dart:math' as math;
import 'package:flutter/material.dart';

@immutable
class FloatingButtonCircle extends StatefulWidget {
  const FloatingButtonCircle({
    Key? key,
    this.initialOpen,
    this.distance,
    this.children,
    this.backgroundColor,
    this.foregroundColor,
    this.childIcon,
  }) : super(key: key);

  final bool? initialOpen;
  final double? distance;
  final List<Widget>? children;
  final backgroundColor;
  final Widget? childIcon;
  final Color? foregroundColor;

  @override
  _FloatingButtonCircleState createState() => _FloatingButtonCircleState();
}

class _FloatingButtonCircleState extends State<FloatingButtonCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPress() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          if (_open)
            Positioned(
                top: -100,
                bottom: -100,
                right: -100,
                left: -100,
                child: InkWell(
                    onTap: _onPress,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white.withOpacity(0.7),
                      //margin: EdgeInsets.only(right: 0),
                    ))),
          _buildTapToCloseCircle(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenCircle(),
        ],
      ),
    );
  }

  //Close Circle
  Widget _buildTapToCloseCircle() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          color: widget.backgroundColor,
          child: InkWell(
            onTap: _onPress,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.close,
                color: widget.foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Open Circle
  Widget _buildTapToOpenCircle() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 1.0 : 1.0,
          _open ? 1.0 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: Duration(milliseconds: 250),
          child: FloatingActionButton(
              onPressed: _onPress,
              backgroundColor: widget.backgroundColor,
              child: widget.childIcon),
        ),
      ),
    );
  }

  //List Circle
  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children!.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children![i],
        ),
      );
    }
    return children;
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  _ExpandingActionButton({
    Key? key,
    this.directionInDegrees,
    this.maxDistance,
    this.progress,
    this.child,
  }) : super(key: key);

  final double? directionInDegrees;
  final double? maxDistance;
  final Animation<double>? progress;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress!,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees! * (math.pi / 180.0),
          progress!.value * maxDistance!,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress!.value) * math.pi / 2,
            child: child,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress!,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    required this.children,
    required this.backgroundColor,
  }) : super(key: key);

  final Widget children;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
        shape: CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        color: backgroundColor,
        child: children);
  }
}
