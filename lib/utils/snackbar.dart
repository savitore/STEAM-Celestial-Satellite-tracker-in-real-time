import 'package:flutter/material.dart';

import 'colors.dart';

/// Shows a floating snackbar with the given [message].
void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
      style: TextStyle(color: ThemeColors.snackBarTextColor),
    ),
    backgroundColor: ThemeColors.snackBarBackgroundColor,
  ));
}
