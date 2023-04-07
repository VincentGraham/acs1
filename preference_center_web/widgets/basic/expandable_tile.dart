import 'package:flutter/material.dart';

/// a list tile that does not depend on a [PreferenceModel]
/// make sure to put this inside a [PageStorage]
class ExpandableTile extends StatefulWidget {
  final List<Widget> actions;
  const ExpandableTile({
    Key? key,
    required this.height,
    required this.maxHeight,
    this.padding,
    this.child,
    this.expandedChild,
    this.expandable = true,
    this.onSizeChange,
    this.actions = const [],
    this.direction = Axis.vertical,
    this.reverse = false,
  }) : super(key: key);

  /// the initial height of the collapsed widget
  final double height;

  /// what size the widget will grow to
  final double maxHeight;

  ///
  final EdgeInsets? padding;

  /// call back to run when the widget expands or collapses
  final ValueChanged<bool>? onSizeChange;

  /// if the expansion is enabled
  final bool expandable;

  /// the initial contents of the widget
  final Widget? child;

  /// the contents of the expanded area
  /// a column wraps the [child] and [children]
  final Widget? expandedChild;

  /// does the widget expand horizontally or vertically
  final Axis direction;

  /// set to [true] if the [child] should be placed after the [expandedChild]
  final bool reverse;

  @override
  ExpandableTileState createState() => ExpandableTileState();
}

class ExpandableTileState extends State<ExpandableTile>
    with SingleTickerProviderStateMixin {
  late final Widget divider;
  late double height;

  // animates the widget expansion
  late final AnimationController controller;
  late Animation<double> heightFactor;

  /// is the widget expanded
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    height = widget.height;
    isOpen = PageStorage.of(context)?.readState(context) as bool? ?? false;
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    heightFactor = controller.drive(CurveTween(curve: Curves.easeInCirc));

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
    if (widget.onSizeChange != null) widget.onSizeChange!(isOpen);
  }

  Widget _builder(BuildContext context, Widget? child) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 36),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRect(
              child: SizedBox(
                height: widget.height,
                child: widget.child,
              ),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.center,
                heightFactor: heightFactor.value,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        hoverColor: Colors.white60,
        onTap: toggleSize,
        child: AnimatedBuilder(
          animation: controller.view,
          builder: _builder,
          child: isOpen || !controller.isDismissed
              ? Offstage(
                  child: TickerMode(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: widget.maxHeight - widget.height,
                        child: widget.expandedChild,
                      ),
                    ),
                    enabled: isOpen || !controller.isDismissed,
                  ),
                  offstage: !isOpen && controller.isDismissed,
                )
              : null,
        ),
      ),
    );
  }
}
