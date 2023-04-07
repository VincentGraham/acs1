import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  const MyButton({
    Key? key,
    this.size = 24.0,
    required this.icon,
    required this.label,
    required this.onClick,
    this.reverse = false,
    this.canResize = true,
    this.maximumSize = double.infinity,
    this.padding = const EdgeInsets.all(8),
    this.color,
    this.iconColor,
    this.labelStyle,
  }) : super(key: key);

  final double size;
  final IconData icon;
  final String label;
  final bool canResize;
  final bool reverse;
  final double maximumSize;
  final void Function() onClick;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? iconColor;
  final TextStyle? labelStyle;

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  bool isTextVisible = false;
  Color color = Colors.white;

  late AnimationController controller;
  late Animation animation;
  late Animation tapDownAnimation;

  late final Widget icon;
  late final Widget text;
  late final Widget endPadding;
  late final Animation<double> widthFactor;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 210),
        reverseDuration: const Duration(milliseconds: 700));
    animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInToLinear);
    widthFactor = controller.drive(CurveTween(curve: Curves.easeInOut));

    icon = Icon(
      widget.icon,
      size: widget.size,
      color: widget.iconColor,
    );

    text = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.fade,
      style: widget.labelStyle,
      // ),
    );

    endPadding = FittedBox(
      fit: BoxFit.scaleDown,
      child: const SizedBox(
        width: 1.0,
        height: 10.0,
      ),
    );
  }

  void setStatus(bool isOpen) {
    if (isOpen == this.isOpen) return;
    setState(() {
      if (isOpen) {
        isTextVisible = true;
        controller.forward();
      } else {
        controller.reverse();
        isTextVisible = false;
      }
      this.isOpen = isOpen;
    });
  }

  List<BoxShadow>? get shadows {
    if (isOpen)
      return const [
        BoxShadow(
          color: Color(0x80000000),
          blurRadius: 12.0,
          offset: Offset(0.0, 5.0),
        )
      ];
    else
      return const [
        BoxShadow(
          color: const Color(0x40000000),
          blurRadius: 8.0,
          offset: Offset(0.0, 3.0),
        )
      ];
  }

  void onTap(bool down) {
    if (down) {
      this.color = Colors.white24;
    } else {
      this.color = Colors.white;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color ?? Colors.white,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setStatus(true),
        onExit: (_) => setStatus(false),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.padding.horizontal),
          child: GestureDetector(onTap: widget.onClick, child: _build(context)
              // // remove this child and use _build instead
              // // implementation not using an animatedbuilder
              // child: Container(
              //   padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              //   width: widget.canResize
              //       ? animation.value * widget.maximumSize + (widget.size + 14)
              //       : widget.size,
              //   height: widget.size + 14,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(90),
              //     color: Colors.white,
              //     boxShadow: shadows,
              //   ),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     textDirection:
              //         widget.reverse ? TextDirection.ltr : TextDirection.rtl,
              //     children: [
              //       icon,
              //       Visibility(
              //         visible: (animation.value > 0.2 && widget.canResize),
              //         child: endPadding,
              //       ),
              //     ],
              //   ),
              // ),
              ),
        ),
      ),
    );
  }

  Widget _build(context) {
    return AnimatedBuilder(
      builder: _builder,
      animation: controller.view,
      child: Offstage(
        child: TickerMode(
          child: Container(
            color: widget.color ?? Colors.white,
            // height: widget.size,
            // width: widget.maximumSize - widget.size,
            child: text,
          ),
          enabled: !controller.isDismissed || isOpen,
        ),
        offstage: controller.isDismissed && !isOpen,
      ),
    );
  }

// the child is in the expanded area
  Widget _builder(BuildContext context, Widget? child) {
    var widgets = [
      Container(
        // height: widget.size,
        width: widget.size,
        color: widget.color ?? Colors.white,
        child: icon,
      ),
      ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor.value,
          child: child,
        ),
      )
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.reverse ? widgets.reversed.toList() : widgets,
    );
  }
}
