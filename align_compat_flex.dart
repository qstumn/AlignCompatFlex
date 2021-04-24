import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

/* author: changhai.qiu  email: qstumn@163.com */

class AlignCompatRow extends _Flex {
  AlignCompatRow({
    Key key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    List<Widget> children = const <Widget>[],
  }) : super(
          children: children,
          key: key,
          direction: Axis.horizontal,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );
}

class AlignCompatColumn extends _Flex {
  AlignCompatColumn({
    Key key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    List<Widget> children = const <Widget>[],
  }) : super(
          children: children,
          key: key,
          direction: Axis.vertical,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );
}

class _Flex extends Flex {
  _Flex({
    Key key,
    Axis direction = Axis.vertical,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    List<Widget> children = const <Widget>[],
  }) : super(
          children: children,
          key: key,
          direction: direction,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _RenderFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
    );
  }
}

class _RenderFlex extends RenderFlex {
  _RenderFlex({
    List<RenderBox> children,
    Axis direction = Axis.horizontal,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
  }) : super(
            children: children,
            direction: direction,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: crossAxisAlignment,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            textBaseline: textBaseline);

  double _getCrossSize(RenderBox child) {
    switch (direction) {
      case Axis.horizontal:
        return child.size.height;
      case Axis.vertical:
        return child.size.width;
    }
    return null;
  }

  @override
  void performLayout() {
    super.performLayout();
    var child = firstChild;
    var crossSize = 0.0;
    while (child != null) {
      final childParentData = child.parentData as FlexParentData;
      if (child is! RenderPositionedBox) {
        crossSize = math.max(crossSize, _getCrossSize(child));
      }
      child = childParentData.nextSibling;
    }
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as FlexParentData;

      if (child is RenderPositionedBox) {
        BoxConstraints innerConstraints = direction == Axis.horizontal
            ? BoxConstraints.tightFor(height: crossSize)
            : BoxConstraints.tightFor(width: crossSize);
        child.layout(innerConstraints, parentUsesSize: true);
      } else {
        double childCrossPosition = 0;
        switch (crossAxisAlignment) {
          case CrossAxisAlignment.start:
            childCrossPosition = 0;
            break;
          case CrossAxisAlignment.end:
            childCrossPosition = crossSize - _getCrossSize(child);
            break;
          case CrossAxisAlignment.center:
            childCrossPosition = crossSize / 2.0 - _getCrossSize(child) / 2.0;
            break;
          case CrossAxisAlignment.stretch:
            childCrossPosition = 0.0;
            break;
          case CrossAxisAlignment.baseline:
          //TODO not supported yet
        }
        switch (direction) {
          case Axis.horizontal:
            childParentData.offset =
                Offset(childParentData.offset.dx, childCrossPosition);
            break;
          case Axis.vertical:
            childParentData.offset =
                Offset(childCrossPosition, childParentData.offset.dy);
            break;
        }
      }
      child = childParentData.nextSibling;
    }
    size = constraints.constrain(direction == Axis.horizontal
        ? Size(size.width, crossSize)
        : Size(crossSize, size.height));
  }
}
