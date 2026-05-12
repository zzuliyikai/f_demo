import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
          if (onRetry != null) const SizedBox(height: 16),
          if (onRetry != null) ElevatedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}