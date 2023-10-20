import 'package:flutter/material.dart';

class FocusMenuItemInfo {
  Widget _menuItemLabel;
  Icon _menuItemIcon;
  Function _onPress;

  FocusMenuItemInfo({required Widget menuItemLabel, required Icon menuItemIcon, required Function onPress})
      : _menuItemLabel = menuItemLabel,
        _menuItemIcon = menuItemIcon,
        _onPress = onPress;

  Widget get menuItemLabel => _menuItemLabel;
  Icon get menuItemIcon => _menuItemIcon;
  Function get onPress => _onPress;
}
