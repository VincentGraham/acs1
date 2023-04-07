import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DropDown extends StatefulWidget {
  final BorderRadius? borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final ValueChanged<int> onChange;
  final double width;
  final double height;
  final List<String> options;
  final String title;

  const DropDown({
    Key? key,
    required this.options,
    required this.borderRadius,
    required this.width,
    required this.height,
    this.backgroundColor = Colors.white38,
    this.iconColor = Colors.black,
    required this.onChange,
    this.title = "Filter",
  }) : super(key: key);

  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> with TickerProviderStateMixin {
  late final GlobalKey _key;
  late final AnimationController _controller;

  // rotation is an implicit animation on the icon
  // late final Animation<double> _rotate;

  bool isOpen = false;

  late OverlayEntry _overlayEntry;
  late Size size;
  late Offset position;
  late int currentValue;
  int? selectedIndex;

  @override
  void initState() {
    _key = GlobalKey();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    size = Size(widget.width, widget.height);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  findButton() {
    RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    size = renderBox.size;
    position = renderBox.localToGlobal(Offset.zero);
  }

  void close() {
    _overlayEntry.remove();
    _controller.reverse();
    isOpen = !isOpen;
  }

  void open() {
    findButton();
    _controller.forward();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context)?.insert(_overlayEntry);
    isOpen = !isOpen;
  }

  void onChange(int value) {
    widget.onChange(value);
    setState(() {
      currentValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: TextButton.icon(
        key: _key,
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _controller,
        ),
        label: Text(
          selectedIndex != null ? widget.options[selectedIndex!] : widget.title,
          style: Theme.of(context).textTheme.button,
        ),
        onPressed: () {
          if (isOpen) {
            close();
          } else {
            open();
          }
        },
      ),
    );
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: position.dy + size.height,
          left: position.dx,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  height: (widget.options.length + 1) * size.height,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                  ),
                  child: Theme(
                    data: ThemeData(
                      iconTheme: IconThemeData(
                        color: widget.iconColor,
                      ),
                    ),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        widget.options.length,
                        (index) {
                          return Expanded(
                            child: DropDownItem(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                                widget.onChange(index);
                                close();
                              },
                              height: size.height,
                              width: size.width,
                              child: Text(widget.options[index],
                                  style: Theme.of(context).textTheme.button),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DropDownItem extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;
  final VoidCallback? onTap;

  const DropDownItem({
    Key? key,
    required this.width,
    required this.height,
    required this.child,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          padding: MaterialStateProperty.all(EdgeInsets.all(12)),
          shape: MaterialStateProperty.all(
              BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
    // return GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     width: width,
    //     height: height,
    //     child: child,
    //   ),
    // );
  }
}
