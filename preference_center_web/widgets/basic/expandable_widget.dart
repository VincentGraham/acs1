import 'package:flutter/material.dart';

/// using [ExpandableTile] instead
class ExpandableWidget extends StatefulWidget {
  const ExpandableWidget({
    Key? key,
    required this.size,
    required this.maxSize,
    required this.child,
    this.hasTopBorder = false,
    this.expandedChild,
    this.padding,
    this.direction = Axis.vertical,
  }) : super(key: key);
  final bool hasTopBorder;
  final Widget child;
  final Widget? expandedChild;

  final double size;
  final double maxSize;
  final EdgeInsets? padding;
  final Axis direction;

  @override
  _ExpandableWidgetState createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Widget divider;
  late final Widget basicInfo;
  late double size;
  late Animation<double> sizeFactor;

  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    size = widget.size;
    isOpen = PageStorage.of(context)?.readState(context) as bool? ?? false;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 250,
      ),
    );
    sizeFactor = controller.drive(CurveTween(curve: Curves.easeInCirc));
    if (isOpen) controller.value = 1.0;
  }

  void toggleSize() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        controller.forward();
      } else {
        controller.reverse();
      }
      PageStorage.of(context)?.writeState(context, isOpen);
    });
  }

  Widget _builder(BuildContext context, Widget? child) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.greenAccent,
      ),
      child: widget.direction == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: _getChildren(child),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: _getChildren(child),
            ),
    );
  }

  List<Widget> _getChildren(Widget? child) {
    return [
      widget.child,
      ClipRect(
        child: Align(
          alignment: Alignment.center,
          heightFactor:
              widget.direction == Axis.vertical ? sizeFactor.value : null,
          widthFactor:
              widget.direction == Axis.horizontal ? sizeFactor.value : null,
          child: child,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => toggleSize(),
      child: AnimatedBuilder(
        animation: controller.view,
        builder: _builder,
        child: isOpen || !controller.isDismissed
            ? Offstage(
                child: TickerMode(
                  child: Container(
                    height: widget.direction == Axis.vertical
                        ? widget.maxSize - widget.size
                        : null,
                    width: widget.direction == Axis.horizontal
                        ? widget.maxSize - widget.size
                        : null,
                    child: widget.child,
                  ),
                  enabled: isOpen || !controller.isDismissed,
                ),
                offstage: !isOpen && controller.isDismissed,
              )
            : null,
      ),
    );
  }
}
