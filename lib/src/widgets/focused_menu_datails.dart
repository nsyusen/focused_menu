import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:focused_menu/src/models/FocusMenuItemInfo.dart';
import 'package:focused_menu/src/models/focused_menu_item.dart';
import 'package:focused_menu/src/widgets/toolbar_actions.dart';

class FocusedMenuDetails extends StatefulWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final double? itemExtent;
  final Size? childSize;
  final Widget child;
  final bool animateMenu;
  final double? blurSize;
  final double? menuWidth;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  /// Actions to be shown in the toolbar.
  final List<Widget>? toolbarActions;

  /// Enable scroll in menu.
  final bool enableMenuScroll;

  const FocusedMenuDetails(
      {Key? key,
      required this.menuItems,
      required this.child,
      required this.childOffset,
      required this.childSize,
      required this.menuBoxDecoration,
      required this.itemExtent,
      required this.animateMenu,
      required this.blurSize,
      required this.blurBackgroundColor,
      required this.menuWidth,
      required this.enableMenuScroll,
      this.bottomOffsetHeight,
      this.menuOffset,
      this.toolbarActions})
      : super(key: key);

  @override
  State<FocusedMenuDetails> createState() => _FocusedMenuDetailsState();
}

class _FocusedMenuDetailsState extends State<FocusedMenuDetails> {
  late List<Future<FocusMenuItemInfo>> _infoFutures;

  @override
  void initState() {
    _infoFutures = widget.menuItems.map((e) {
      return e.infoFuture();
    }).toList() as List<Future<FocusMenuItemInfo>>;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = widget.menuItems.length * (widget.itemExtent ?? 50.0);

    final maxMenuWidth = widget.menuWidth ?? (size.width * 0.70);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (widget.childOffset.dx + maxMenuWidth) < size.width
        ? widget.childOffset.dx
        : (widget.childOffset.dx - maxMenuWidth + widget.childSize!.width);
    final topOffset =
        (widget.childOffset.dy + menuHeight + widget.childSize!.height) < size.height - widget.bottomOffsetHeight!
            ? widget.childOffset.dy + widget.childSize!.height + widget.menuOffset!
            : widget.childOffset.dy - menuHeight - widget.menuOffset!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: widget.blurSize ?? 4, sigmaY: widget.blurSize ?? 4),
                  child: Container(
                    color: (widget.blurBackgroundColor ?? Colors.black).withOpacity(0.7),
                  ),
                )),
            Positioned(
              top: topOffset,
              left: leftOffset,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                tween: Tween(begin: 0.0, end: 1.0),
                child: Container(
                  width: maxMenuWidth,
                  height: menuHeight,
                  decoration: widget.menuBoxDecoration ??
                      BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          boxShadow: [const BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 1)]),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: ListView.builder(
                      itemCount: widget.menuItems.length,
                      padding: EdgeInsets.zero,
                      physics: widget.enableMenuScroll ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        FocusedMenuItem item = widget.menuItems[index];
                        Widget listItem = FutureBuilder<FocusMenuItemInfo>(
                            future: _infoFutures[index],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                FocusMenuItemInfo itemInfo = snapshot.data!;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    itemInfo.onPress();
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(bottom: 0),
                                    height: widget.itemExtent ?? 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          itemInfo.menuItemLabel,
                                          if (itemInfo.menuItemIcon != null) ...[itemInfo.menuItemIcon!]
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(bottom: 0),
                                  height: widget.itemExtent ?? 50,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.pink,
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            });
                        if (widget.animateMenu) {
                          return TweenAnimationBuilder(
                              builder: (context, dynamic value, child) {
                                return Transform(
                                  transform: Matrix4.rotationX(1.5708 * value),
                                  alignment: Alignment.bottomCenter,
                                  child: child,
                                );
                              },
                              tween: Tween(begin: 1.0, end: 0.0),
                              duration: Duration(milliseconds: index * 200),
                              child: listItem);
                        } else {
                          return listItem;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (widget.toolbarActions != null) ToolbarActions(toolbarActions: widget.toolbarActions!),
            Positioned(
                top: widget.childOffset.dy,
                left: widget.childOffset.dx,
                child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                        width: widget.childSize!.width, height: widget.childSize!.height, child: widget.child))),
          ],
        ),
      ),
    );
  }
}
