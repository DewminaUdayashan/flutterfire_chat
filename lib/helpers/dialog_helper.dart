import 'package:flutter/material.dart';

extension DialogHelperExt on BuildContext {
  void showLoading() => showDialog(
        context: this,
        builder: (_) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

  void dismissDialog() => Navigator.canPop(this) ? Navigator.pop(this) : null;
}
