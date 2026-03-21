import 'package:flutter/material.dart';

void showTimedSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 5),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(message),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 0.0),
            duration: duration,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white70),
              minHeight: 2,
            ),
          ),
        ],
      ),
      duration: duration,
      action: action,
    ),
  );
}
