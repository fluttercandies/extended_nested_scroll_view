//pack your inner scrollables which are in  NestedScrollView body
//so that it can find the active scrollable
//compare with NestedScrollViewInnerScrollPositionKeyBuilder
import 'package:flutter/material.dart';

class NestedScrollViewInnerScrollPositionKeyWidget extends StatefulWidget {
  const NestedScrollViewInnerScrollPositionKeyWidget(
      this.scrollPositionKey, this.child);
  final Key scrollPositionKey;
  final Widget child;
  static State of(BuildContext context) {
    return context.findAncestorStateOfType<
        _NestedScrollViewInnerScrollPositionKeyWidgetState>();
  }

  @override
  _NestedScrollViewInnerScrollPositionKeyWidgetState createState() =>
      _NestedScrollViewInnerScrollPositionKeyWidgetState();
}

class _NestedScrollViewInnerScrollPositionKeyWidgetState
    extends State<NestedScrollViewInnerScrollPositionKeyWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
