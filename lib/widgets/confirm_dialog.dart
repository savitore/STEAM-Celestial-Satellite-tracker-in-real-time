import 'package:flutter/material.dart';

import '../utils/colors.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    this.onCancel,
    required this.title,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  final String title;
  final String message;
  final Function onConfirm;
  final Function? onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: ThemeColors.primaryColor),
          ),
        ],
      ),
      backgroundColor: ThemeColors.backgroundColor,
      content: Text(
        message,
        style: TextStyle(color: ThemeColors.textPrimary),
      ),
      actions: [
        TextButton(
          child: Text(
            'CANCEL',
            style: TextStyle(color: ThemeColors.alert),
          ),
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            }
          },
        ),
        TextButton(
          child: Text(
            'YES',
            style: TextStyle(color: ThemeColors.success),
          ),
          onPressed: () {
            onConfirm();
          },
        ),
      ],
    );
  }
}
