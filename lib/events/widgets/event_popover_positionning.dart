import 'package:flutter/material.dart';

Offset computePopoverPosition(
  BuildContext context,
  RenderBox anchor,
  Size popoverSize,
) {
  final screen = MediaQuery.of(context).size;
  final anchorPos = anchor.localToGlobal(Offset.zero);

  double dx = anchorPos.dx + anchor.size.width + 8;
  double dy = anchorPos.dy;

  if (dx + popoverSize.width > screen.width) {
    dx = anchorPos.dx - popoverSize.width - 8;
  }

  if (dy + popoverSize.height > screen.height) {
    dy = screen.height - popoverSize.height - 12;
  }

  return Offset(dx, dy);
}
