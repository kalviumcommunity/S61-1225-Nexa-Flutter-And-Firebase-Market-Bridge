// lib/widgets/loading_widget.dart

import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final bool showIcon;

  const LoadingWidget({
    Key? key,
    this.message,
    this.color,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon)
            CircularProgressIndicator(
              color: color ?? const Color(0xFF11823F),
              strokeWidth: 3,
            ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}