import 'package:flutter/material.dart';

import '../utils/colors.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    this.onCancel,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.buttonText
  }) : super(key: key);

  final String title;
  final String message;
  final Function onConfirm;
  final Function? onCancel;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: ThemeColors.textPrimary),
          ),
        ],
      ),
      backgroundColor: ThemeColors.backgroundColor,
      content: Text(
        message,
        style: TextStyle(color: ThemeColors.textSecondary),
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: ThemeColors.primaryColor),
          ),
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            }
          },
        ),
        TextButton(
          child: Text(
            buttonText,
            style: TextStyle(color: ThemeColors.primaryColor),
          ),
          onPressed: () {
            onConfirm();
          },
        ),
      ],
    );
  }
}
