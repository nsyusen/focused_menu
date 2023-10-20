import 'package:flutter/material.dart';
import 'package:focused_menu/src/models/FocusMenuItemInfo.dart';

class FocusedMenuItem {
  Future<FocusMenuItemInfo> Function() infoFuture;
  bool? isDefaultAction;

  FocusedMenuItem({
    required this.infoFuture,
    this.isDefaultAction = false,
  });
}
